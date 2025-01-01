var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Read the deployment mode from environment variables
var deploymentMode = Environment.GetEnvironmentVariable("DEPLOYMENT_MODE")?.ToUpper() ?? "SELFHOSTED";
Console.WriteLine($"Deployment Mode: {deploymentMode}");

var daprHttpPort = Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3602";
var daprGrpcPort = Environment.GetEnvironmentVariable("DAPR_GRPC_PORT") ?? "60002";

// Configure Dapr client based on deployment mode
builder.Services.AddDaprClient(builder =>
{
    if (deploymentMode == "DOCKER")
    {
        // When running in Docker, use the Dapr sidecar's service name
        builder.UseHttpEndpoint($"http://commandsservice-dapr:{daprHttpPort}")
               .UseGrpcEndpoint($"http://commandsservice-dapr:{daprGrpcPort}");
    }
    else
    {
        // When running in Self-Hosted mode, use localhost
        builder.UseHttpEndpoint($"http://localhost:{daprHttpPort}")
               .UseGrpcEndpoint($"http://localhost:{daprGrpcPort}");
    }
});

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
