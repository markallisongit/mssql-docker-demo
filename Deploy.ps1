[cmdletbinding()]
param ()
$config = Get-Content .\config.json -Raw -Encoding UTF8 | ConvertFrom-Json
$ContainerInfo = Get-Content .\ContainerInfo.json -raw -Encoding UTF8 | ConvertFrom-Json
$SaPassword=$config.SaPassword
$Instance = "$($config.DockerHost),$ContainerPort"
$RemoteDrive = 'C'
$RemoteDirectory = 'Temp'
$FileToCopy = "ContainerInfo.json"
$ContainerName = $ContainerInfo.ContainerName

# copy a file to the docker host
try {
    $Session = New-PSSession -ComputerName $config.DockerHost
    New-Item -Path "\\$($config.DockerHost)\$RemoteDrive$\$RemoteDirectory" -type directory -Force 
    Copy-Item ".\$FileToCopy" -Destination "$RemoteDrive`:\$RemoteDirectory\" -ToSession $Session
    
    Invoke-Command -Session $Session -ScriptBlock {
        & docker exec -d $($using:ContainerName) powershell New-Item "$($using:RemoteDrive):\$($using:RemoteDirectory)" -ItemType Directory -Force
        
        # For some unknown reason we have to wait a few seconds before copying into a new dir!
        Start-Sleep -Seconds 5
        & docker cp "$($using:RemoteDrive):\$($using:RemoteDirectory)\$using:FileToCopy" "$($using:ContainerName):/$($using:RemoteDirectory)/$using:FileToCopy"
    }
}

finally {
    Get-PSSession -ComputerName $config.DockerHost | Remove-PSSession
}
& $env:SQLPACKAGE /Action:Publish /SourceFile:bin\Debug\single-pipeline-demo.dacpac /TargetServerName:$Instance /TargetDatabaseName:single-pipeline-demo /TargetUser:sa /TargetPassword:$SaPassword
