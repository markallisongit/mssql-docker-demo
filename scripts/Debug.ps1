cls
Set-Location 'C:\Repos\mssql-docker-demo'
Import-Module .\mssql-docker-demo.psm1 -Force

$InformationPreference='Continue'
$VerbosePreference='Continue'
$output = New-MssqlContainer -DockerHost 'foxglove.duck.loc' -SaPassword 'edU*9Fqd2dFr!TrGr6Ds' -ContainerType Windows
# Remove-WindowsMssqlContainer -DockerHost 'foxglove.duck.loc' -ContainerName 'mssql-50004'
Invoke-Command -ComputerName 'Foxglove.duck.loc' {& docker ps -a}
$output