[cmdletbinding()]
param ()
$config = Get-Content .\config.json -Raw -Encoding UTF8 | ConvertFrom-Json
$ContainerPort = (Get-Content .\ContainerInfo.json -raw -Encoding UTF8 | ConvertFrom-Json).ContainerPort
$SaPassword=$config.SaPassword
$Instance = "$($config.DockerHost),$ContainerPort"

& $env:SQLPACKAGE /Action:Publish /SourceFile:bin\Debug\single-pipeline-demo.dacpac /TargetServerName:$Instance /TargetDatabaseName:single-pipeline-demo /TargetUser:sa /TargetPassword:$SaPassword
