$configFile = "../dapr/config/config.yaml"

dapr run `
    --app-id commandsservice `
    --app-port 5230 `
    --dapr-http-port 3602 `
    --dapr-grpc-port 60002 `
    --config $configFile `
    --resources-path ../dapr/components/selfhosted `
    --log-level debug `
    dotnet run