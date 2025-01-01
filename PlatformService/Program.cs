using Dapr.Client;
using Microsoft.EntityFrameworkCore;
using PlatformService.Data;
using PlatformService.SyncDataServices.Http;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Read the deployment mode from environment variables
var deploymentMode = Environment.GetEnvironmentVariable("DEPLOYMENT_MODE")?.ToUpper() ?? "SELFHOSTED";
Console.WriteLine($"Deployment Mode: {deploymentMode}");

// Define Dapr ports (ensure these match your configurations)
var daprHttpPort = Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3601";
var daprGrpcPort = Environment.GetEnvironmentVariable("DAPR_GRPC_PORT") ?? "60001";

// Configure Dapr client based on deployment mode
builder.Services.AddDaprClient(builder =>
{
    if (deploymentMode == "DOCKER")
    {
        // When running in Docker, use the Dapr sidecar's service name
        builder.UseHttpEndpoint($"http://platformservice-dapr:{daprHttpPort}")
               .UseGrpcEndpoint($"http://platformservice-dapr:{daprGrpcPort}");
    }
    else
    {
        // When running in Self-Hosted mode, use localhost
        builder.UseHttpEndpoint($"http://localhost:{daprHttpPort}")
               .UseGrpcEndpoint($"http://localhost:{daprGrpcPort}");
    }
});

builder.Services.AddSingleton<ICommandDataClient, HttpCommandDataClient>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseInMemoryDatabase("InMemDb"));

builder.Services.AddScoped<IPlatformRepo, PlatformRepo>();

var app = builder.Build();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

PrepDb.PrepPopulation(app);

app.Run();
