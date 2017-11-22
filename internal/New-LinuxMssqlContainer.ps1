Function New-LinuxMssqlContainer
{
<#
.SYNOPSIS 
Creates a SQL Server 2017 container on Linux

.DESCRIPTION
Creates a new container on Linux. The Linux machine must have the latest version of docker installed and have ssh keys set up.

.PARAMETER DockerHost
The name of the container host server

.PARAMETER SaPassword
The password for the sa account. Must be complex.

.PARAMETER StartPortRange
The starting port number to scan from to look for an unused port for the MSSQL Service.

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
        [Parameter(Mandatory=$true,Position=1)][string]$SaPassword,
        [Parameter(Mandatory=$true)][int]$StartPortRange,
        [Parameter(Mandatory=$true)][string]$KeyFilePath,
        [Parameter(Mandatory=$true)][string]$DockerUserName
    )
    Process
    {
        if ((Get-Module posh-ssh).Count -eq 0) {
            Install-Module posh-ssh -Scope CurrentUser
        }

        $credential = New-Object System.Management.Automation.PSCredential ($DockerUserName, (New-Object System.Security.SecureString))
        $sesh = New-SSHSession -ComputerName $DockerHost -Credential $credential -KeyFile $KeyFilePath

        $ContainerPort = $StartPortRange
        Write-Information "Start range for port scan: $StartPortRange"
        do {
            Write-Verbose "Checking if port $ContainerPort in use..."
            $ErrorMessage = (Invoke-SSHCommand -Command "exec 6<>/dev/tcp/127.0.0.1/$ContainerPort" -SessionId $sesh.SessionId).Error
            if([string]::IsNullOrEmpty($ErrorMessage)) {
                # we didn't get an error which means the port responded, so something is using it
                $ContainerPort++
            }    
        }
        until ($ErrorMessage.Contains("Connection refused"))

        $ContainerName = "mssql-$ContainerPort"

        Write-Information "Creating container: $ContainerName on port $ContainerPort"
        $dockerCmd = "docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=$SaPassword' -p $($ContainerPort):1433 --name $ContainerName -d microsoft/mssql-server-linux"
        $result = Invoke-SSHCommand -Command $dockerCmd -SessionId $sesh.SessionId
        if ($result.ExitStatus -ne 0) {
            throw $result.Error
        }

        $Instance = "$($DockerHost),$ContainerPort"

        $ServerName = Confirm-MssqlConnection -Instance $Instance -SaPassword $SaPassword
        Write-Information "Logged in! ServerName returned: $ServerName. Container ready."
        $removed = Remove-SSHSession -SessionId $sesh.SessionId
        return @{
            "ContainerPort" = $ContainerPort;
            "ContainerName" = $ContainerName;
            "ContainerId" = $result.Output;
        }         
    }
}