using DemoWebAPIWithSQLiteDbInDocker.Models;
using Microsoft.EntityFrameworkCore;

namespace DemoWebAPIWithSQLiteDbInDocker.Data
{
    public class ProductDbContext(DbContextOptions<ProductDbContext> options) : DbContext(options)
    {
        public DbSet<Product> Products { get; set; }
    }
}
