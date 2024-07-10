# 🚀 End of Hassle: Say Goodbye to Complex Setups! No More Headaches – Run .NET Web API with SQLite in Docker 🐳
# Introduction
We're diving into the world of containers with a step-by-step guide on running your .NET Web API with an SQLite database connected in Docker! 🐳🔗 If you've ever wondered how to streamline your development and deployment process, this video is for you. Stick around, because by the end, you'll have your API running in a containerized environment with ease. Let's get started! 🌟

# Scenario:
"Imagine you're developing a microservice architecture for an e-commerce application. Each service has its own database, and you want a lightweight, file-based database for your inventory service. SQLite is perfect for this! Now, to ensure consistency across development, staging, and production environments, you'll want to containerize this setup. Using Docker, you can easily spin up your Web API connected to an SQLite database, making your deployment seamless and scalable. 📦🛍️"

# Create Model
    public class Product
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public int Quantity { get; set; }
    }

  # Create Connectiong String
    "ConnectionStrings": {
    "SQLiteConnection": "Data Source=YoutubeDb.db"
  }

# Create Db Context
    namespace DemoWebAPIWithSQLiteDbInDocker.Data
    {
        public class ProductDbContext(DbContextOptions<ProductDbContext> options) : DbContext(options)
        {
            public DbSet<Product> Products { get; set; }
        }
    }

  # Register Db Context
    builder.Services.AddDbContext<ProductDbContext>
      (o=>o.UseSqlite(builder.Configuration.GetConnectionString("SQLiteConnection")));

# Create Minimal Api Endpoints
    namespace DemoWebAPIWithSQLiteDbInDocker.Models
    {
        public static class ProductEndpoints
    {
    	public static void MapProductEndpoints (this IEndpointRouteBuilder routes)
        {
            var group = routes.MapGroup("/api/Product").WithTags(nameof(Product));
    
            group.MapGet("/", async (ProductDbContext db) =>
            {
                return await db.Products.ToListAsync();
            })
            .WithName("GetAllProducts")
            .WithOpenApi();
    
            group.MapGet("/{id}", async Task<Results<Ok<Product>, NotFound>> (int id, ProductDbContext db) =>
            {
                return await db.Products.AsNoTracking()
                    .FirstOrDefaultAsync(model => model.Id == id)
                    is Product model
                        ? TypedResults.Ok(model)
                        : TypedResults.NotFound();
            })
            .WithName("GetProductById")
            .WithOpenApi();
    
            group.MapPut("/{id}", async Task<Results<Ok, NotFound>> (int id, Product product, ProductDbContext db) =>
            {
                var affected = await db.Products
                    .Where(model => model.Id == id)
                    .ExecuteUpdateAsync(setters => setters
                      .SetProperty(m => m.Id, product.Id)
                      .SetProperty(m => m.Name, product.Name)
                      .SetProperty(m => m.Description, product.Description)
                      .SetProperty(m => m.Quantity, product.Quantity)
                      );
                return affected == 1 ? TypedResults.Ok() : TypedResults.NotFound();
            })
            .WithName("UpdateProduct")
            .WithOpenApi();
    
            group.MapPost("/", async (Product product, ProductDbContext db) =>
            {
                db.Products.Add(product);
                await db.SaveChangesAsync();
                return TypedResults.Created($"/api/Product/{product.Id}",product);
            })
            .WithName("CreateProduct")
            .WithOpenApi();
    
            group.MapDelete("/{id}", async Task<Results<Ok, NotFound>> (int id, ProductDbContext db) =>
            {
                var affected = await db.Products
                    .Where(model => model.Id == id)
                    .ExecuteDeleteAsync();
                return affected == 1 ? TypedResults.Ok() : TypedResults.NotFound();
            })
            .WithName("DeleteProduct")
            .WithOpenApi();
        }
    }}

# Map the Endpoint
    app.MapProductEndpoints();
    
# Create Docker File
    # This stage is used when running from VS in fast mode (Default for Debug configuration)
    FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
    USER app
    WORKDIR /app
    EXPOSE 8080   
    
    # This stage is used to build the service project
    FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
    ARG BUILD_CONFIGURATION=Release
    WORKDIR /src
    COPY ["DemoWebAPIWithSQLiteDbInDocker/DemoWebAPIWithSQLiteDbInDocker.csproj", "DemoWebAPIWithSQLiteDbInDocker/"]
    RUN dotnet restore "./DemoWebAPIWithSQLiteDbInDocker/DemoWebAPIWithSQLiteDbInDocker.csproj"
    COPY . .
    WORKDIR "/src/DemoWebAPIWithSQLiteDbInDocker"
    RUN dotnet build "./DemoWebAPIWithSQLiteDbInDocker.csproj" -c $BUILD_CONFIGURATION -o /app/build
    
    # This stage is used to publish the service project to be copied to the final stage
    FROM build AS publish
    ARG BUILD_CONFIGURATION=Release
    RUN dotnet publish "./DemoWebAPIWithSQLiteDbInDocker.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false
    
    # This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
    FROM base AS final
    WORKDIR /app
    COPY --from=publish /app/publish .
    COPY DemoWebAPIWithSQLiteDbInDocker/YoutubeDb.db ./
    
    ENTRYPOINT ["dotnet", "DemoWebAPIWithSQLiteDbInDocker.dll"]


# Create Docker-Compose File
    services:
      webapi:
        build:
          context: .
          dockerfile: Dockerfile
        image: youtubeapi
        ports:
            - "8080:8080" # Http
        volumes:
            - ./DemoWebAPIWithSQLiteDbInDocker/YoutubeDb.db:/app/YoutubeDb.db
        environment:
            - ASPNETCORE_URLS=http://+:8080;
            - ASPNETCORE_ENVIRONMENT=Development


//app.UseHttpsRedirection();
  # Build and Run
    - docker-compose build
    - docker-compose up
    
![image](https://github.com/Netcode-Hub/DemoWebAPIWithSQLiteDbInDocker/assets/110794348/b6fe69b4-d5b9-479f-8c63-9258ebad569b) 
![image](https://github.com/Netcode-Hub/DemoWebAPIWithSQLiteDbInDocker/assets/110794348/e62fb436-05af-4a52-ad09-fbfaa67e3247)
![image](https://github.com/Netcode-Hub/DemoWebAPIWithSQLiteDbInDocker/assets/110794348/eb2ec9a6-b2c1-496c-9825-4dd182eb8d74)

Summary:
"In today's tutorial, we covered how to set up and run a .NET Web API with an SQLite database inside a Docker container. We started with a basic project, configured the SQLite connection string, and wrote our Dockerfile. Then, we used Docker Compose to bring it all together, ensuring our environment is consistent and portable. This setup is perfect for lightweight, file-based database needs, especially in microservice architectures. 💡🔧"

# Here's a follow-up section to encourage engagement and support for Netcode-Hub:
🌟 Get in touch with Netcode-Hub! 📫
1. GitHub: [Explore Repositories](https://github.com/Netcode-Hub/Netcode-Hub) 🌐
2. Twitter: [Stay Updated](https://twitter.com/NetcodeHub) 🐦
3. Facebook: [Connect Here](https://web.facebook.com/NetcodeHub) 📘
4. LinkedIn: [Professional Network](https://www.linkedin.com/in/netcode-hub-90b188258/) 🔗
5. Email: Email: [business.netcodehub@gmail.com](mailto:business.netcodehub@gmail.com) 📧
   
# ☕️ If you've found value in Netcode-Hub's work, consider supporting the channel with a coffee!
1. Buy Me a Coffee: [Support Netcode-Hub](https://www.buymeacoffee.com/NetcodeHub) ☕️
