using Dapr.Client;
using PlatformService.Dtos;

namespace PlatformService.SyncDataServices.Http;
public class HttpCommandDataClient : ICommandDataClient
{
    private readonly DaprClient _daprClient;

    public HttpCommandDataClient(DaprClient daprClient)
    {
        _daprClient = daprClient;
    }

    public async Task SendPlatformCommand(PlatformReadDto plat)
    {
        // "commandsservice" is the app ID of the service you want to invoke
        // "/api/c/platforms" is the route in that service.
        await _daprClient.InvokeMethodAsync<PlatformReadDto>(
            "commandsservice",
            "api/c/platforms",
            plat
        );
        Console.WriteLine("--> Sync POST to CommandsService was OK!");
    }
}
