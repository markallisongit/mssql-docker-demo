Function Remove-MssqlContainer
{
<#
.SYNOPSIS 
Removes a SQL Server 2017 container on either Windows, Linux or Azure

.DESCRIPTION
Removes a SQL Server 2017 container on either Windows, Linux or Azure. Can be stopped or running.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER ContainerName
The name of the container

.PARAMETER ContainerType
The type of container. Can be Windows, Linux, Azure

.PARAMETER KeyFilePath
The path to the private ssh key if creating on a linux host.

.PARAMETER DockerUserName
The name of the docker user name for linux hosts, usually root.

.NOTES
Author: Mark Allison

.EXAMPLE   

#>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][string]$DockerHost,
        [Parameter(Mandatory=$true,Position=1)][string]$ContainerName,
        [Parameter(Mandatory=$true,Position=2)][ValidateSet('Windows','Linux','Azure')][string]$ContainerType,
        [Parameter(Mandatory=$false)][string]$KeyFilePath,
        [Parameter(Mandatory=$false)][string]$DockerUserName

    )
    Process
    {
        $output=$null
        switch ($ContainerType)
        {
            'Windows' {
                $output = Remove-WindowsMssqlContainer -DockerHost $DockerHost -ContainerName $ContainerName
            }
            
            'Linux' {
                if (([string]::IsNullOrEmpty($KeyFilePath)) -or ([string]::IsNullOrEmpty($DockerUserName)))
                {
                    throw 'Linux containers require a path to the ssh key AND the user name'
                } else {
                    $output = Remove-LinuxMssqlContainer -DockerHost $DockerHost -ContainerName $ContainerName -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName
                }
            }

            'Azure' {
                throw "Azure containers not implemented yet"
            }
        }
        return $output
    }
}