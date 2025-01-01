using PlatformService.Dtos;

namespace PlatformService.SyncDataServices.Http;

public interface ICommandDataClient
{
    Task SendPlatformCommand(PlatformReadDto plat);
}
