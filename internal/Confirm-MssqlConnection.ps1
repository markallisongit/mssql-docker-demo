Function Confirm-MssqlConnection
{
<#
.SYNOPSIS 
Connects to a Sql Server and makes sure a query can be run

.DESCRIPTION
Runs SELECT @@SERVERNAME against the instance.

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