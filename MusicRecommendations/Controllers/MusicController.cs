using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

[ApiController]
[Route("api")]
public class MusicController : ControllerBase
{
    private readonly KafkaService _kafkaService;

    public MusicController(KafkaService kafkaService)
    {
        _kafkaService = kafkaService;
    }

    [HttpPost("submit_preferences")]
    public async Task<IActionResult> SubmitPreferences([FromBody] UserPreferences preferences)
    {
        preferences.Tempo /= 200.0f; // Normalizar tempo
        await _kafkaService.SendPreferences(preferences);
        return Ok(new { status = "success", message = "Preferencias enviadas" });
    }

    [HttpGet("get_recommendations")]
    public IActionResult GetRecommendations()
    {
        var recommendations = _kafkaService.GetLatestRecommendations();
        if (string.IsNullOrEmpty(recommendations))
        {
            return Ok(new { message = "No hay recomendaciones disponibles aún" });
        }
        return Ok(recommendations);
    }
}
