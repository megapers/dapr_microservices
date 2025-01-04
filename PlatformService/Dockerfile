FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/out .

# Expose ports
ENV ASPNETCORE_HTTP_PORTS=
ENV HTTP_PORTS=
ENV ASPNETCORE_URLS http://*:5012

EXPOSE 5012/tcp
ENTRYPOINT ["dotnet", "PlatformService.dll"]