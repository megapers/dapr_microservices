$path = $MyInvocation.MyCommand.Path | Split-Path

& docker build --tag megapers/commandsservice:1.0 "$path/../CommandsService"
& docker build --tag megapers/platformservice:1.0 "$path/../PlatformService"

& docker push megapers/commandsservice:1.0
& docker push megapers/platformservice:1.0




