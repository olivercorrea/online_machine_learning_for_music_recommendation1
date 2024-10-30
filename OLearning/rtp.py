import json
from confluent_kafka import Consumer, Producer
from confluent_kafka.admin import AdminClient, NewTopic
from scipy.spatial.distance import cosine
from collections import deque
import threading
import time

# Configuración de Kafka
KAFKA_BROKER = 'localhost:9092'
KAFKA_TOPIC = 'popular_music3'
KAFKA_USER_PREFERENCES_TOPIC = 'user_preferences'
KAFKA_RECOMMENDATIONS_TOPIC = 'music_recommendations'

class MusicRecommender:
    def __init__(self):
        self.tracks_history = deque(maxlen=1000)
        self.feature_weights = {
            'danceability': 1.0,
            'energy': 1.0,
            'tempo': 0.7,
            'valence': 0.8,
            'acousticness': 0.6
        }
        self.producer = Producer({
            'bootstrap.servers': KAFKA_BROKER,
            'queue.buffering.max.messages': 1000000,
            'queue.buffering.max.ms': 1,
            'batch.num.messages': 100,
            'linger.ms': 1
        })
        print("Inicializando MusicRecommender...")

    def extract_features(self, track_info):
        try:
            features = {
                'danceability': float(track_info['audio_features']['danceability']),
                'energy': float(track_info['audio_features']['energy']),
                'tempo': float(track_info['audio_features']['tempo']) / 200.0,
                'valence': float(track_info['audio_features']['valence']),
                'acousticness': float(track_info['audio_features']['acousticness'])
            }
            print(f"Características extraídas exitosamente: {features}")
            return features
        except KeyError as e:
            print(f"Error al extraer características: {e}")
            print(f"Track info recibida: {track_info}")
            return None

    def calculate_similarity(self, features1, features2):
        try:
            print(f"Calculando similitud entre:\nFeatures1: {features1}\nFeatures2: {features2}")
            weighted_features1 = []
            weighted_features2 = []

            for feature, value in features1.items():
                weight = self.feature_weights.get(feature, 1.0)
                weighted_features1.append(value * weight)
                weighted_features2.append(features2[feature] * weight)

            if not weighted_features1 or not weighted_features2:
                print("Vector de características vacío")
                return 0

            similarity = 1 - cosine(weighted_features1, weighted_features2)
            print(f"Similitud calculada: {similarity}")
            return similarity
        except Exception as e:
            print(f"Error al calcular similitud: {e}")
            return 0

    def process_new_track(self, track_info):
        try:
            print(f"Procesando nueva pista: {track_info['track']} - {track_info['artist']}")
            features = self.extract_features(track_info)
            if features is not None:
                track_data = {
                    'track': track_info['track'],
                    'artist': track_info['artist'],
                    'features': features
                }
                self.tracks_history.append(track_data)
                print(f"Pista agregada al historial. Total de pistas: {len(self.tracks_history)}")
        except Exception as e:
            print(f"Error procesando track: {e}")

    def get_recommendations(self, query_features, n_recommendations=5):
        print(f"Buscando recomendaciones para preferencias: {query_features}")
        if not self.tracks_history:
            print("No hay pistas en el historial para generar recomendaciones")
            return []

        try:
            # Normalizar las preferencias del usuario
            normalized_preferences = {
                'danceability': float(query_features['Danceability']) / 100.0,
                'energy': float(query_features['Energy']) / 100.0,
                'valence': float(query_features['Valence']) / 100.0,
                'acousticness': float(query_features['Acousticness']) / 100.0,
                'tempo': float(query_features['Tempo'])  # Ya normalizado
            }
            print(f"Preferencias normalizadas: {normalized_preferences}")

            recommendations = []
            for track in self.tracks_history:
                try:
                    similarity = self.calculate_similarity(normalized_preferences, track['features'])
                    recommendations.append({
                        'track': track['track'],
                        'artist': track['artist'],
                        'similarity': similarity
                    })
                except Exception as e:
                    print(f"Error al procesar track para recomendación: {e}")
                    continue

            sorted_recommendations = sorted(recommendations, key=lambda x: x['similarity'], reverse=True)[:n_recommendations]
            print(f"Recomendaciones generadas: {sorted_recommendations}")
            return sorted_recommendations
        except Exception as e:
            print(f"Error al generar recomendaciones: {e}")
            return []

    def send_recommendations_to_kafka(self, recommendations):
        try:
            recommendation_data = {
                "timestamp": str(time.time()),
                "recommendations": [
                    {
                        "track": rec["track"],
                        "artist": rec["artist"],
                        "similarity": float(rec["similarity"])
                    }
                    for rec in recommendations
                ]
            }

            message = json.dumps(recommendation_data)
            print(f"Enviando recomendaciones a Kafka: {message}")

            self.producer.produce(
                KAFKA_RECOMMENDATIONS_TOPIC,
                value=message.encode('utf-8')
            )
            self.producer.flush(timeout=1)
            print("Recomendaciones enviadas exitosamente a Kafka")

        except Exception as e:
            print(f"Error al enviar recomendaciones a Kafka: {e}")

def music_catalog_consumer(recommender):
    print("Iniciando consumidor del catálogo de música...")
    consumer = Consumer({
        'bootstrap.servers': KAFKA_BROKER,
        'group.id': 'music_catalog_group',
        'auto.offset.reset': 'earliest'
    })
    consumer.subscribe([KAFKA_TOPIC])

    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                print(f"Error de Kafka: {msg.error()}")
                continue

            try:
                track_info = json.loads(msg.value().decode('utf-8'))
                print(f"Nueva pista recibida del catálogo: {track_info['track']}")
                recommender.process_new_track(track_info)
            except json.JSONDecodeError as e:
                print(f"Error decodificando mensaje: {e}")
                continue

    except KeyboardInterrupt:
        consumer.close()

def user_preferences_consumer(recommender):
    print("Iniciando consumidor de preferencias de usuario...")
    consumer = Consumer({
        'bootstrap.servers': KAFKA_BROKER,
        'group.id': 'user_preferences_group',
        'auto.offset.reset': 'latest'
    })
    consumer.subscribe([KAFKA_USER_PREFERENCES_TOPIC])

    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                print(f"Error de Kafka: {msg.error()}")
                continue

            try:
                preferences = json.loads(msg.value().decode('utf-8'))
                print(f"Nuevas preferencias de usuario recibidas: {preferences}")
                recommendations = recommender.get_recommendations(preferences)
                if recommendations:
                    recommender. send_recommendations_to_kafka(recommendations)
                else:
                    print("No se generaron recomendaciones")
            except json.JSONDecodeError as e:
                print(f"Error decodificando preferencias: {e}")
                continue

    except KeyboardInterrupt:
        consumer.close()

def ensure_topics_exist():
    admin_client = AdminClient({'bootstrap.servers': KAFKA_BROKER})
    topics_to_create = [
        NewTopic(KAFKA_TOPIC, num_partitions=1, replication_factor=1),
        NewTopic(KAFKA_USER_PREFERENCES_TOPIC, num_partitions=1, replication_factor=1),
        NewTopic(KAFKA_RECOMMENDATIONS_TOPIC, num_partitions=1, replication_factor=1)
    ]

    existing_topics = admin_client.list_topics().topics
    for topic in topics_to_create:
        if topic.topic not in existing_topics:
            try:
                futures = admin_client.create_topics([topic])
                for topic_name, future in futures.items():
                    future.result()
                print(f"Tópico {topic.topic} creado exitosamente")
            except Exception as e:
                print(f"Error al crear el tópico {topic.topic}: {e}")

def main():
    ensure_topics_exist()
    recommender = MusicRecommender()

    # Iniciar consumidor del catálogo de música
    catalog_thread = threading.Thread(target=music_catalog_consumer, args=(recommender,))
    catalog_thread.daemon = True
    catalog_thread.start()

    # Iniciar consumidor de preferencias de usuario
    preferences_thread = threading.Thread(target=user_preferences_consumer, args=(recommender,))
    preferences_thread.daemon = True
    preferences_thread.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nCerrando el programa...")
        recommender.producer.flush()

if __name__ == "__main__":
    main()
