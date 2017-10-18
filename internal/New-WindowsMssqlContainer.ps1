Function New-WindowsMssqlContainer
{
<#
.SYNOPSIS 
Creates a SQL Server 2017 container on  Windows

.DESCRIPTION
Creates a new container on Windows. The Windows machine must be Windows Server 2016 or later with the Container services installed.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER SaPassword
The password for the sa account. Must be complex.

.PARAMETER StartPortRange
The starting port number to scan from to look for an unused port for the MSSQL Service.

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
        [Parameter(Mandatory=$true)][int]$StartPortRange
    )
    Process
    {
        $ContainerPort = $StartPortRange
        Write-Information "Start range for port scan: $StartPortRange"
        do {
            Write-Verbose "Checking if port $ContainerPort is in use..."
            $InUse = (Test-NetConnection -ComputerName $DockerHost -Port $ContainerPort).TcpTestSucceeded
            if($InUse) {
                $ContainerPort++
            }    
        }
        until ($InUse -eq $false)

        $ContainerName = "mssql-$ContainerPort"
        $dockerCmd = "docker run -d -p $($ContainerPort):1433 -e sa_password=$SaPassword -e ACCEPT_EULA=Y --name $ContainerName microsoft/mssql-server-windows-developer"

        Write-Information "Creating container: $ContainerName on port $ContainerPort"
        Invoke-Command -ComputerName $DockerHost -ScriptBlock { & cmd.exe /c $using:dockerCmd } 

        $Instance = "$($DockerHost),$ContainerPort"

        $ServerName = Confirm-MssqlConnection -Instance $Instance -SaPassword $SaPassword

        Write-Information "Logged in! ServerName returned: $ServerName. Container ready."

        # return the config
        return @{"ContainerPort" = $ContainerPort;"ContainerName" = $ContainerName;}
        
    }
}