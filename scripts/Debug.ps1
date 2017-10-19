# Windows
cls
Set-Location 'C:\Repos\mssql-docker-demo'
Import-Module .\mssql-docker-demo.psm1 -Force

$InformationPreference='SilentlyContinue'
$VerbosePreference='SilentlyContinue'

$DockerHost = 'foxglove.duck.loc'
$SaPassword = 'edU*9Fqd2dFr!TrGr6Ds'
$output = New-MssqlContainer -DockerHost $DockerHost -SaPassword $SaPassword -ContainerType Windows

$output.ContainerPort

Remove-MssqlContainer -DockerHost $DockerHost -ContainerName 'mssql-50003' -ContainerType Windows
Invoke-Command -ComputerName $DockerHost {& docker ps -a}


# Linux
cls
Import-Module .\mssql-docker-demo.psd1 -Force
$DockerHost = 'neon.localdomain'
$SaPassword = 'edU*9Fqd2dFr!TrGr6Ds'
$KeyFilePath = 'C:\Users\mark\Documents\ssh\mark.allison@sabin.io-openssh-privkey.ppk'
$DockerUserName = 'root'

$InformationPreference='Continue'
$VerbosePreference='Continue'

$output = New-MssqlContainer -DockerHost $DockerHost -SaPassword $SaPassword -ContainerType Linux -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName
$output
Remove-MssqlContainer -DockerHost $DockerHost -ContainerName 'mssql-50000' -ContainerType Linux -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName

invoke-pester