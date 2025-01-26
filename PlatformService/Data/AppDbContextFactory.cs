using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace PlatformService.Data
{
    public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
    {
        public AppDbContext CreateDbContext(string[] args)
        {
            Console.WriteLine("--> Using AppDbContextFactory to create context for migrations");

            var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();
            optionsBuilder.UseSqlServer("Server=localhost,1433;Initial Catalog=platformsdb;User ID=sa;Password=pa55w0rd!;TrustServerCertificate=True");

            return new AppDbContext(optionsBuilder.Options);
        }
    }
}