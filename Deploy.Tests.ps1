$config = Get-Content .\config.json -raw -Encoding UTF8 | ConvertFrom-Json
$ContainerPort = (Get-Content .\ContainerInfo.json -raw -Encoding UTF8 | ConvertFrom-Json).ContainerPort
$Instance = "$($config.DockerHost),$ContainerPort"
Import-Module SqlServer
Describe "Deploy tests" -Tags 'Public' {

    It 'Deploys' {
        $tableExists = (Invoke-Sqlcmd -ServerInstance $Instance -User sa -Password $config.SaPassword -Database "single-pipeline-demo" -Query "select count(*) [count] from sys.tables where name = 'ATable'").count
        $tableExists | Should Be 1
    }
}