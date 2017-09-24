[cmdletbinding()]
param ()

if ((Get-Module posh-ssh).Count -eq 0) {
    Install-Module posh-ssh
}

Get-SSHTrustedHost
$config = Get-Content .\config.json -Raw -Encoding UTF8 | ConvertFrom-Json

$credential = New-Object System.Management.Automation.PSCredential ($config.DockerUserName, (New-Object System.Security.SecureString))
$sesh = New-SSHSession -ComputerName $config.DockerHost -Credential $credential -KeyFile $config.KeyFilePath

[int]$ContainerPort = $config.MSSQLPort
Write-Information "Start range for port scan: $($config.MSSQLPort)"
do {
    Write-Verbose "Checking if port $ContainerPort in use..."
    $ErrorMessage = (Invoke-SSHCommand -Command "exec 6<>/dev/tcp/127.0.0.1/$ContainerPort" -SessionId $sesh.SessionId).Error
    if([string]::IsNullOrEmpty($ErrorMessage)) {
        # we didn't get an error which means the port responded, so something is using it
        $ContainerPort++
    }    
}
until ($ErrorMessage.Contains("Connection refused"))

$ContainerName = "mssql-$($env:BRANCH_NAME)-$ContainerPort"
$SaPassword=$config.SaPassword

Write-Information "Creating container: $ContainerName on port $ContainerPort"
$dockerCmd = "docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=$SaPassword' -p $($ContainerPort):1433 --name $ContainerName -d microsoft/mssql-server-linux"
$result = Invoke-SSHCommand -Command $dockerCmd -SessionId $sesh.SessionId

if ($result.ExitStatus -ne 0) {
    throw $result.Error
}

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

Remove-SSHSession -SessionId $sesh.SessionId
@{"ContainerPort" = $ContainerPort;"ContainerName" = $ContainerName;} | ConvertTo-Json | Out-File -FilePath 'ContainerInfo.json' -Encoding UTF8
