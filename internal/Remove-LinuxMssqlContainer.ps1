Function Remove-LinuxMssqlContainer
{
<#
.SYNOPSIS 
Removes a SQL Server 2017 container on Linux

.DESCRIPTION
Removes a new container on Linux. The container can be running or stopped.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER ContainerName
The name of the container

.PARAMETER KeyFilePath
The path to the private ssh key

.PARAMETER DockerUserName
The name of the docker user name for linux hosts, usually 'root'.

.NOTES
Author: Mark Allison

.EXAMPLE   

#>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][string]$DockerHost,
        [Parameter(Mandatory=$true,Position=1)][string]$ContainerName,
        [Parameter(Mandatory=$true,Position=2)][string]$KeyFilePath,
        [Parameter(Mandatory=$true,Position=3)][string]$DockerUserName
    )
    Process
    {
        if ((Get-Module posh-ssh).Count -eq 0) {
            Install-Module posh-ssh -Scope CurrentUser
        }

        $credential = New-Object System.Management.Automation.PSCredential ($DockerUserName, (New-Object System.Security.SecureString))
        $sesh = New-SSHSession -ComputerName $DockerHost -Credential $credential -KeyFile $KeyFilePath

        Write-Information "Removing container $ContainerName"
        $dockerRemove = "docker rm -f $ContainerName"
        $result = Invoke-SSHCommand -Command $dockerRemove -SessionId $sesh.SessionId

        if ($result.ExitStatus -ne 0) {
            throw $result.Error
        }        
        $removed = Remove-SSHSession -SessionId $sesh.SessionId
    }
}