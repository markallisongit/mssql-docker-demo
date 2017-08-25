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