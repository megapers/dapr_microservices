# start-all.ps1

# Function to wait for a service to be ready by attempting a TCP connection
function Wait-ServiceReady {
    param(
        [string]$hostname,
        [int]$port,
        [int]$timeoutSeconds = 60
    )

    Write-Host "Waiting for ${hostname}:$port to be ready..."
    $startTime = Get-Date
    while ((Get-Date) -lt $startTime.AddSeconds($timeoutSeconds)) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect($hostname, $port)
            if ($tcpClient.Connected) {
                $tcpClient.Close()
                Write-Host "${hostname}:$port is ready."
                return $true
            }
        }
        catch {
            # Do nothing, just wait
        }
        Start-Sleep -Seconds 2
    }

    Write-Error "${hostname}:$port did not become ready within $timeoutSeconds seconds."
    return $false
}

# Function to start an existing PowerShell script
function Start-ExistingScript {
    param(
        [string]$scriptPath
    )

    if (Test-Path $scriptPath) {
        Write-Host "Starting script: $scriptPath"
        # Start the script in a new PowerShell process
        $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -PassThru
        return $process
    }
    else {
        Write-Error "Script not found: $scriptPath"
        return $null
    }
}

# Define path to docker-components.yaml
$dockerComposeFile = "docker-components.yaml"

# Start Docker Compose services
Write-Host "Starting Docker Compose services..."
docker-compose -f $dockerComposeFile up -d

# Wait for RabbitMQ to be ready
if (-not (Wait-ServiceReady -hostname "localhost" -port 5672 -timeoutSeconds 60)) {
    Write-Error "RabbitMQ is not ready. Exiting."
    exit 1
}

# Define paths to existing selfhosted scripts
$platformServiceScript = ".\PlatformService\start-selfhosted.ps1"
$commandsServiceScript = ".\CommandsService\start-selfhosted.ps1"

# Start PlatformService
$platformServiceProcess = Start-ExistingScript -scriptPath $platformServiceScript

# Start CommandsService
$commandsServiceProcess = Start-ExistingScript -scriptPath $commandsServiceScript

Write-Host "Both PlatformService and CommandsService have been started."

# Function to handle cleanup on script termination
function Cleanup {
    Write-Host "`nInitiating cleanup..."

    # Stop the child processes
    if ($platformServiceProcess -and !$platformServiceProcess.HasExited) {
        Write-Host "Stopping PlatformService..."
        $platformServiceProcess.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 5
        if (!$platformServiceProcess.HasExited) {
            Write-Host "Forcefully terminating PlatformService..."
            $platformServiceProcess.Kill()
        }
    }

    if ($commandsServiceProcess -and !$commandsServiceProcess.HasExited) {
        Write-Host "Stopping CommandsService..."
        $commandsServiceProcess.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 5
        if (!$commandsServiceProcess.HasExited) {
            Write-Host "Forcefully terminating CommandsService..."
            $commandsServiceProcess.Kill()
        }
    }

    # Stop Docker Compose services
    Write-Host "Stopping Docker Compose services..."
    docker-compose -f $dockerComposeFile down

    Write-Host "Cleanup complete."
}

# Register the cleanup function to run on script exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup } | Out-Null

# Keep the script running to maintain child processes
Write-Host "All services are running. Press Ctrl+C to stop and clean up."
while ($true) {
    Start-Sleep -Seconds 10
}
