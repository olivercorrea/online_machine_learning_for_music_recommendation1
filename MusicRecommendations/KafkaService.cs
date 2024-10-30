using Confluent.Kafka;
using System.Text.Json;
using System.Threading.Tasks;

public class KafkaService
{
    private const string KafkaBroker = "localhost:9092";
    private const string RecommendationsTopic = "music_recommendations";
    private const string UserPreferencesTopic = "user_preferences";

    private readonly IProducer<Null, string> _producer;
    private string _latestRecommendations;
    private readonly object _lock = new object();

    public KafkaService()
    {
        var config = new ProducerConfig { BootstrapServers = KafkaBroker };
        _producer = new ProducerBuilder<Null, string>(config).Build();
    }

    public void StartConsumer()
    {
        var consumerConfig = new ConsumerConfig
        {
            BootstrapServers = KafkaBroker,
            GroupId = "web_app_group",
            AutoOffsetReset = AutoOffsetReset.Latest
        };

        Task.Run(() =>
        {
            using var consumer = new ConsumerBuilder<Null, string>(consumerConfig).Build();
            consumer.Subscribe(RecommendationsTopic);

            while (true)
            {
                try
                {
                    var consumeResult = consumer.Consume();
                    if (consumeResult != null)
                    {
                        lock (_lock)
                        {
                            _latestRecommendations = consumeResult.Message.Value;
                        }
                        Console.WriteLine($"Nuevas recomendaciones recibidas: {consumeResult.Message.Value}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error consumiendo mensaje: {ex.Message}");
                }
            }
        });
    }

    public async Task SendPreferences(UserPreferences preferences)
    {
        var message = new Message<Null, string>
        {
            Value = JsonSerializer.Serialize(preferences)
        };

        await _producer.ProduceAsync(UserPreferencesTopic, message);
    }

    public string GetLatestRecommendations()
    {
        lock (_lock)
        {
            return _latestRecommendations;
        }
    }
}
