$configFile = "../dapr/config/config.yaml"

dapr run `
    --app-id platformservice `
    --app-port 5012 `
    --dapr-http-port 3601 `
    --dapr-grpc-port 60001 `
    --config $configFile `
    --resources-path ../dapr/components/selfhosted `
    --log-level debug `
    dotnet run