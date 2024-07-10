
# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080 
#EXPOSE 5001  


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