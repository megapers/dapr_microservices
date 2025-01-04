using PlatformService.Models;

namespace PlatformService.Data;

public static class PrepDb
{
    public static async Task PrepPopulation(IApplicationBuilder app)
    {
        using (var serviceScope = app.ApplicationServices.CreateScope())
        {
            await SeedData(serviceScope.ServiceProvider.GetService<AppDbContext>());
        }
    }

    private static async Task SeedData(AppDbContext context)
    {
        if (!context.Platforms.Any())
        {
            Console.WriteLine("--> Seeding Data...");

            context.Platforms.AddRange(
                new Platform() { Name = "Dot Net", Publisher = "Microsoft", Cost = "Free" },
                new Platform() { Name = "SQL Server Express", Publisher = "Microsoft", Cost = "Free" },
                new Platform() { Name = "Kubernetes", Publisher = "Cloud Native Computing Foundation", Cost = "Free" }
            );
            await context.SaveChangesAsync();
        }
        else
        {
            Console.WriteLine("--> We already have data");
        }
    }

}
