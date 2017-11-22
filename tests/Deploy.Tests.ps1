$moduleRoot = Split-Path $PSScriptRoot
$module = 'mssql-docker-demo'
Get-Module $module | Remove-Module -Force
Import-Module "$moduleRoot\$module.psm1" -Force
$sut = (Split-Path $moduleRoot) -replace '.Tests\.', '.'

$config = Get-Content "$PSScriptRoot\test.config.json" -raw -Encoding UTF8 | ConvertFrom-Json

# Import-Module SqlServer
Describe "Container tests" -Tags 'Public' {

    It 'Create Windows Container' {
        New-MssqlContainer -DockerHost $config.WindowsDockerHost -SaPassword $config.SaPassword -ContainerType Windows
        # $windowsContainerInfo.ContainerId | Should Not BeNullOrEmpty
        # [int]$windowsContainerInfo.ContainerPort | Should BeGreaterThan [int]$config.StartPortRange

    }

}

<#
    It 'Create Linux Container' {
        $linuxContainerInfo = New-MssqlContainer -DockerHost $config.LinuxDockerHost -SaPassword $config.SaPassword -ContainerType Linux -KeyFilePath $config.KeyFilePath -DockerUserName $config.DockerUserName
        [int]$output.ContainerPort | Should BeGreaterThan [int]$config.StartPortRange

    }    

    It 'Remove Windows Container' {
        $removeWindowsContainerOutput = Remove-MssqlContainer -DockerHost $config.WindowsDockerHost -ContainerName $windowsContainerInfo.ContainerName -ContainerType Windows
        [int]$output.ContainerPort | Should BeGreaterThan [int]$config.StartPortRange

    }  

    It 'Remove Linux Container' {
        $removeLinuxContainerOutput = Remove-MssqlContainer -DockerHost $config.LinuxDockerHost -ContainerName $linuxContainerInfo.ContainerName -ContainerType Linux -KeyFilePath $config.KeyFilePath -DockerUserName $config.DockerUserName
        [int]$output.ContainerPort | Should BeGreaterThan [int]$config.StartPortRange

    }      
    
     It 'Deploys to Windows' {
        $tableExists = (Invoke-Sqlcmd -ServerInstance $Instance -User sa -Password $config.SaPassword -Database "single-pipeline-demo" -Query "select count(*) [count] from sys.tables where name = 'ATable'").count
        $tableExists | Should Be 1
    } #>