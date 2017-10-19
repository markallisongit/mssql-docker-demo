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

Remove-WindowsMssqlContainer -DockerHost $DockerHost -ContainerName 'mssql-50000'
Invoke-Command -ComputerName $DockerHost {& docker ps -a}


# Linux
cls
Import-Module .\mssql-docker-demo.psm1 -Force
$DockerHost = 'neon.localdomain'
$SaPassword = 'edU*9Fqd2dFr!TrGr6Ds'
$KeyFilePath = 'C:\Users\mark\Documents\ssh\mark.allison@sabin.io-openssh-privkey.ppk'
$DockerUserName = 'root'

$InformationPreference='Continue'
$VerbosePreference='SilentlyContinue'

$output = New-MssqlContainer -DockerHost $DockerHost -SaPassword $SaPassword -ContainerType Linux -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName
$output
Remove-LinuxMssqlContainer -DockerHost $DockerHost -ContainerName 'mssql-50000' -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName

invoke-pester