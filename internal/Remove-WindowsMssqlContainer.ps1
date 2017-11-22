Function Remove-WindowsMssqlContainer
{
<#
.SYNOPSIS 
Removes a SQL Server 2017 container on  Windows

.DESCRIPTION
Removes a new container on Windows. The container can be running or stopped.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER ContainerName
The name of the container

.NOTES
Author: Mark Allison

.EXAMPLE   

#>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][string]$DockerHost,
        [Parameter(Mandatory=$true,Position=1)][string]$ContainerName
    )
    Process
    {
        Write-Information "Removing container $ContainerName"
        $dockerRemove = "docker rm -f $ContainerName"
        Invoke-Command -ComputerName $DockerHost -ScriptBlock { & cmd.exe /c $using:dockerRemove }
    }
}