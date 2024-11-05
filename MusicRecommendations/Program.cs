using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Agregar servicios al contenedor.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<KafkaService>();

// Configurar CORS para permitir solicitudes desde cualquier origen
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins",
        builder => builder.AllowAnyOrigin() // Permitir cualquier origen
                          .AllowAnyMethod() // Permitir cualquier método (GET, POST, etc.)
                          .AllowAnyHeader()); // Permitir cualquier encabezado
});

var app = builder.Build();

// Configurar el pipeline de solicitud HTTP.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAllOrigins"); // Aplicar la política de CORS
app.UseAuthorization();
app.MapControllers();

// Iniciar el servicio Kafka
var kafkaService = app.Services.GetRequiredService<KafkaService>();
kafkaService.StartConsumer();

app.Run();
