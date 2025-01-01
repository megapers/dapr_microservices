var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

var daprHttpPort = Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3602";
var daprGrpcPort = Environment.GetEnvironmentVariable("DAPR_GRPC_PORT") ?? "60002";
builder.Services.AddDaprClient(builder => builder
    .UseHttpEndpoint($"http://commandsservice-dapr:{daprHttpPort}")
    .UseGrpcEndpoint($"http://commandsservice-dapr:{daprGrpcPort}"));

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
