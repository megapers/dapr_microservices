# start-all.ps1

# Function to check if a TCP port is open
function Test-Port {
    param(
        [string]$Hostname,
        [int]$Port,
        [int]$Timeout = 5
    )
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $result = $connection.BeginConnect($Hostname, $Port, $null, $null)
        $wait = $result.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)
        if (!$wait) {
            $connection.Close()
            return $false
        }
        $connection.EndConnect($result)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Function to start a script asynchronously with environment variables and logging
function Start-ScriptAsync {
    param(
        [string]$ScriptPath,
        [string]$WorkingDirectory,
        [hashtable]$EnvironmentVars,
        [string]$LogFilePath
    )
    Start-Process -FilePath "pwsh.exe" `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" `
                  -WorkingDirectory $WorkingDirectory `
                  -WindowStyle Hidden `
                  -Environment $EnvironmentVars `
                  -RedirectStandardOutput $LogFilePath `
                  -RedirectStandardError "$($LogFilePath)_error.log"
}

# Set deployment mode in parent process
$env:DEPLOYMENT_MODE = "SELFHOSTED"

# Start Docker Compose services
try {
    Write-Host "Starting Docker Compose services..."
    docker-compose -f docker-components.yaml up -d
}
catch {
    Write-Error "Failed to start Docker Compose services: $_"
    exit 1
}

# Wait for RabbitMQ to be ready
Write-Host "Waiting for RabbitMQ to be ready..."
while (-not (Test-Port -Hostname "localhost" -Port 5672 -Timeout 2)) {
    Write-Host "RabbitMQ not ready yet. Waiting..."
    Start-Sleep -Seconds 2
}
Write-Host "RabbitMQ is ready."

# Define paths to existing selfhosted scripts
$projectRoot = $PWD
$platformServiceScript = Join-Path -Path $projectRoot -ChildPath "PlatformService\start-selfhosted.ps1"
$commandsServiceScript = Join-Path -Path $projectRoot -ChildPath "CommandsService\start-selfhosted.ps1"

# Define environment variables (already set DEPLOYMENT_MODE)
$envVars = @{
    DEPLOYMENT_MODE = "SELFHOSTED"
}

# Define log file paths
$platformServiceLog = Join-Path -Path $projectRoot -ChildPath "PlatformService\platformservice_output.log"
$commandsServiceLog = Join-Path -Path $projectRoot -ChildPath "CommandsService\commandsservice_output.log"

# Start PlatformService asynchronously with logging
try {
    Write-Host "Starting PlatformService..."
    Start-ScriptAsync -ScriptPath $platformServiceScript `
                      -WorkingDirectory (Join-Path -Path $projectRoot -ChildPath "PlatformService") `
                      -EnvironmentVars $envVars `
                      -LogFilePath $platformServiceLog
}
catch {
    Write-Error "Failed to start PlatformService: $_"
    exit 1
}

# Wait for Dapr sidecar to initialize (adjust as needed)
Start-Sleep -Seconds 5

# Start CommandsService asynchronously with logging
try {
    Write-Host "Starting CommandsService..."
    Start-ScriptAsync -ScriptPath $commandsServiceScript `
                      -WorkingDirectory (Join-Path -Path $projectRoot -ChildPath "CommandsService") `
                      -EnvironmentVars $envVars `
                      -LogFilePath $commandsServiceLog
}
catch {
    Write-Error "Failed to start CommandsService: $_"
    exit 1
}

Write-Host "Both PlatformService and CommandsService have been started."

# Function to handle cleanup on script termination
function Cleanup {
    Write-Host "`nInitiating cleanup..."

    # Stop Docker Compose services
    Write-Host "Stopping Docker Compose services..."
    docker-compose -f docker-components.yaml down

    Write-Host "Cleanup complete."
}

# Register the cleanup function to run on script exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup } | Out-Null

# Keep the script running to maintain child processes
Write-Host "All services are running. Press Ctrl+C to stop and clean up."
while ($true) {
    Start-Sleep -Seconds 10
}
