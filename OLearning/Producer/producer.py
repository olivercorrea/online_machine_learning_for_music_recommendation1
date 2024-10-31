import json
import time
from confluent_kafka import Producer
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from dotenv import load_dotenv
import os

# Cargar variables de entorno
load_dotenv()

# Obtener variables
s_client_ID = os.getenv('SPOTIPY_CLIENT_ID')
s_client_secret = os.getenv('SPOTIPY_CLIENT_SECRET')

# Configuración de Kafka
KAFKA_BROKER = 'broker:9092'
KAFKA_TOPIC = 'popular_music3'

# Inicializar el productor de Kafka
producer = Producer({'bootstrap.servers': KAFKA_BROKER})

# Autenticación con Spotify
client_credentials_manager = SpotifyClientCredentials(client_id=s_client_ID, client_secret=s_client_secret)
sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)

# Set para mantener registro de artistas ya procesados
processed_artists = set()

def get_new_artists(limit=50):
    """Obtiene nuevos artistas populares que no han sido procesados anteriormente"""
    new_artists = []

    # Obtener varias categorías de playlists
    categories = sp.categories(limit=10)['categories']['items']

    for category in categories:
        # Obtener playlists populares de cada categoría
        playlists = sp.category_playlists(category['id'], limit=5)['playlists']['items']

        for playlist in playlists:
            tracks = sp.playlist_tracks(playlist['id'], limit=20)

            for track in tracks['items']:
                if track['track'] and track['track']['artists']:
                    artist = track['track']['artists'][0]

                    # Solo procesar artistas que no hemos visto antes
                    if artist['id'] not in processed_artists:
                        artist_info = sp.artist(artist['id'])
                        new_artists.append({
                            'id': artist['id'],
                            'name': artist['name'],
                            'popularity': artist_info['popularity'],
                            'genres': artist_info['genres']
                        })
                        processed_artists.add(artist['id'])

    # Ordenar por popularidad
    return sorted(new_artists, key=lambda x: x['popularity'], reverse=True)

def get_artist_top_track_and_genre(artist_id, artist_name):
    """Obtiene la canción más popular y su género para un artista"""
    try:
        # Obtener la canción más popular
        top_tracks = sp.artist_top_tracks(artist_id)
        if not top_tracks['tracks']:
            return None

        top_track = top_tracks['tracks'][0]

        # Obtener detalles de la canción
        track_features = sp.audio_features(top_track['id'])[0]

        return {
            'artist_name': artist_name,
            'track_name': top_track['name'],
            'popularity': top_track['popularity'],
            'genres': sp.artist(artist_id)['genres'],
            'features': {
                'danceability': track_features['danceability'],
                'energy': track_features['energy'],
                'tempo': track_features['tempo'],
                'valence': track_features['valence'],
                'acousticness': track_features['acousticness']
            }
        }
    except Exception as e:
        print(f"Error processing artist {artist_name}: {e}")
        return None

def main():
    while True:
        try:
            # Obtener nuevos artistas
            new_artists = get_new_artists()

            for artist in new_artists:
                # Obtener información detallada de la canción más popular
                track_info = get_artist_top_track_and_genre(artist['id'], artist['name'])

                if track_info:
                    # Crear mensaje para ML
                    message = {
                        'timestamp': time.time(),
                        'artist': track_info['artist_name'],
                        'track': track_info['track_name'],
                        'popularity': track_info['popularity'],
                        'genres': track_info['genres'],
                        'audio_features': track_info['features']
                    }

                    # Enviar a Kafka
                    producer.produce(
                        KAFKA_TOPIC,
                        key=artist['id'].encode('utf-8'),
                        value=json.dumps(message).encode('utf-8')
                    )
                    producer.poll(0)

                    print(f"Enviado: {message}")

                # Pequeña pausa para no sobrecargar la API
                time.sleep(1)

            # Esperar antes de buscar más artistas
            time.sleep(30)

        except Exception as e:
            print(f"Error en el loop principal: {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()
