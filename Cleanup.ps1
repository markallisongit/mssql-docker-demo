[cmdletbinding()]
param ()
$InformationPreference = 'Continue'

$dockerHost = (Get-Content .\config.json -Raw -Encoding UTF8 | ConvertFrom-Json).DockerHost
$ContainerName = (Get-Content .\ContainerInfo.json -raw -Encoding UTF8 | ConvertFrom-Json).ContainerName

Write-Information "Stopping container $ContainerName"
$dockerStop = "docker stop $ContainerName"
Invoke-Command -ComputerName $dockerHost -ScriptBlock { & cmd.exe /c $using:dockerStop }

Write-Information "Removing container $ContainerName"
$dockerRemove = "docker rm $ContainerName"
Invoke-Command -ComputerName $dockerHost -ScriptBlock { & cmd.exe /c $using:dockerRemove }