Function Confirm-MssqlConnection
{
<#
.SYNOPSIS 
Creates a SQL Server 2017 container on  Windows

.DESCRIPTION
Creates a new container on Windows. The Windows machine must be Windows Server 2016 or later with the Container services installed.

.PARAMETER Instance
The Sql Server instance name with port number.

.PARAMETER SaPassword
The password for the sa account. Must be complex.

.NOTES
Author: Mark Allison

.EXAMPLE   

#>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][string]$Instance,
        [Parameter(Mandatory=$true,Position=1)][string]$SaPassword
    )
    Process
    {

        Import-Module SqlServer
        Write-Information "Logging in to $Instance."
        $ServerName = $null
        do {
            $savedPreference = $ErrorActionPreference
            $ErrorActionPreference = 'SilentlyContinue'
            Start-Sleep -s 1
            try {
                $ServerName = (Invoke-Sqlcmd -ServerInstance $Instance -User sa -Password $SaPassword -Query "select @@SERVERNAME ServerName" -ErrorAction 'SilentlyContinue').ServerName
            }
            catch [System.Data.SqlClient.SqlException]
            {
                Write-Information "."
                continue
            }
        }   
        until
            ([string]::IsNullOrEmpty($ServerName) -eq $false)
        $ErrorActionPreference = $savedPreference
        return $ServerName
    }
}