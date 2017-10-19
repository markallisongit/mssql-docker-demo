Function New-MssqlContainer
{
<#
.SYNOPSIS 
Creates a SQL Server 2017 container on either Windows, Linux or Azure Container Service

.DESCRIPTION
Contains cmdlets to create a new container on Windows, Linux or Azure Container Service. If deploying on-premise, the Windows machine must be Windows Server 2016 or later with the Container services installed. If on Linux, then docker must be installed.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER SaPassword
The password for the sa account. Must be complex.

.PARAMETER ContainerType
The type of container. Can be Windows, Linux, Azure

.PARAMETER StartPortRange
The starting port number to scan from to look for an unused port for the MSSQL Service.

.PARAMETER KeyFilePath
The path to the private ssh key if creating on a linux host.

.PARAMETER DockerUserName
The name of the docker user name for linux hosts, usually root.

.PARAMETER Verbose
Shows details of the build, if omitted minimal information is output.

.NOTES
Author: Mark Allison

.EXAMPLE   

#>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][string]$DockerHost,
        [Parameter(Mandatory=$true,Position=1)][string]$SaPassword,
        [Parameter(Mandatory=$true,Position=2)][ValidateSet('Windows','Linux','Azure')][string]$ContainerType,
        [Parameter(Mandatory=$false)][int]$StartPortRange=50000,
        [Parameter(Mandatory=$false)][string]$KeyFilePath,
        [Parameter(Mandatory=$false)][string]$DockerUserName

    )
    Process
    {
        $output=$null
        switch ($ContainerType)
        {
            'Windows' {
                $output = New-WindowsMssqlContainer -DockerHost $DockerHost -SaPassword $SaPassword -StartPortRange $StartPortRange
            }
            
            'Linux' {
                if (([string]::IsNullOrEmpty($KeyFilePath)) -or ([string]::IsNullOrEmpty($DockerUserName)))
                {
                    throw 'Linux containers require a path to the ssh key AND the user name'
                } else {
                    New-LinuxMssqlContainer -DockerHost $DockerHost -SaPassword $SaPassword -StartPortRange $StartPortRange -KeyFilePath $KeyFilePath -DockerUserName $DockerUserName
                }
            }

            'Azure' {
                throw "Azure containers not implemented yet"
            }
        }
        return $output
    }
}