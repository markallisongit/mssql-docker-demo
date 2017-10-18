Function New-MssqlContainer
{
<#
.SYNOPSIS 
Creates a SQL Server 2017 container on either Windows, Linux or Azure Container Service

.DESCRIPTION
Contains cmdlets to create a new container on Windows, Linux or Azure Container Service. If deploying on-premise, the Windows machine must be Windows Server 2016 or later with the Container services installed. If on Linux, then docker must be installed.



.PARAMETER Verbose
Shows details of the build, if omitted minimal information is output.

.NOTES
Author: Mark Allison

Requires: 
	Microsoft.Data.Tools.Msbuild nuget package installed. This module will attempt to auto-install it if missing.
	MSBuild installed. This module will attempt to auto-install it if missing.
	Nuget installed. This module will attempt to auto-install it if missing.
    Admin rights.

.EXAMPLE   
Invoke-DatabaseBuild -DatabaseProjectPath C:\Projects\MyDatabaseProject

Creates a dacpac from the project found in directory C:\Projects\MyDatabaseProject
#>

[cmdletbinding()]
param ()

$config = Get-Content .\config.json -Raw -Encoding UTF8 | ConvertFrom-Json

[int]$ContainerPort = $config.MSSQLPort
Write-Information "Start range for port scan: $($config.MSSQLPort)"
do {
    Write-Verbose "Checking if port $ContainerPort in use..."
    $InUse = (Test-NetConnection -ComputerName $config.DockerHost -Port $ContainerPort).TcpTestSucceeded
    if($InUse) {
        $ContainerPort++
    }    
}
until ($InUse -eq $false)

$ContainerName = "mssql-$($env:BRANCH_NAME)-$ContainerPort"
$SaPassword=$config.SaPassword
$dockerCmd = "docker run -d -p $($ContainerPort):1433 -e sa_password=$SaPassword -e ACCEPT_EULA=Y --name $ContainerName microsoft/mssql-server-windows-developer"

Write-Information "Creating container: $ContainerName on port $ContainerPort"
Invoke-Command -ComputerName $config.DockerHost  -ScriptBlock { & cmd.exe /c $using:dockerCmd } 

$Instance = "$($config.DockerHost),$ContainerPort"

Import-Module SqlServer
Write-Information "Logging in to $Instance."
$ServerName = $null
do {
    Start-Sleep -s 1
    try {
        $ServerName = (Invoke-Sqlcmd -ServerInstance $Instance -User sa -Password $config.SaPassword -Query "select @@SERVERNAME ServerName").ServerName
    }
    catch [System.Data.SqlClient.SqlException]
    {
        Write-Information "."
        continue
    }
}   
until
    ([string]::IsNullOrEmpty($ServerName) -eq $false)
Write-Information "Logged in! ServerName returned: $ServerName. Container ready."

# write out the config for other scripts to read in later
@{"ContainerPort" = $ContainerPort;"ContainerName" = $ContainerName;} | ConvertTo-Json | Out-File -FilePath 'ContainerInfo.json' -Encoding UTF8