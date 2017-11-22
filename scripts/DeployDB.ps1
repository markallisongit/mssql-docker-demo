[cmdletbinding()]
param (
	[parameter(Mandatory=$true)][string]$Dacpac,
    [parameter(Mandatory=$true)][string]$InstanceName,
	[parameter(Mandatory=$true)][string]$DatabaseName,
	[parameter(Mandatory=$false)][string]$PublishProfile,
	[parameter(Mandatory=$false)][string]$UserName,
	[parameter(Mandatory=$false)][securestring]$Password,
	[parameter(Mandatory=$false)][string]$NugetVersion='4.3.0',
    [parameter(Mandatory=$false)][string][ValidateSet('Publish','Script')]$Action = 'Publish')

$ProjectPath = (Get-Item $PSScriptRoot).FullName
Write-Verbose "ProjectPath: $ProjectPath"
Set-Location $ProjectPath

# grab nuget commandline from internet
$nugetURL = "https://dist.nuget.org/win-x86-commandline/v$NugetVersion/nuget.exe"
Write-Verbose "Downloading nuget from $nugetUrl"
$wc = New-Object Net.WebClient
$wc.DownloadFile($nugetURL, "$ProjectPath\nuget.exe") 

if ([string]::IsNullOrEmpty($PublishProfile)) {
	$PublishProfile = "$ProjectPath\$DatabaseName.publish.xml"
}

# install MS Data Tools
$package = 'Microsoft.Data.Tools.Msbuild'
Write-Verbose "Installing package $package using nuget"
& "$ProjectPath\nuget" install $package -ExcludeVersion 

# run sql package to deploy database
$SQLPackage = "$ProjectPath\$package\lib\net*\sqlpackage.exe"
[string[]]$SQLPackageParams = "/Action:$Action", "/TargetServerName:$InstanceName", "/TargetDatabaseName:$DatabaseName", "/SourceFile:$Dacpac", "/Profile:$PublishProfile"

if(-not [string]::IsNullOrEmpty($UserName)) {
	$PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
	$SQLPackageParams += "/TargetUser:$UserName", "/TargetPassword:$PlainTextPassword"
}

if ($Action -eq 'Script')
{
	$SQLPackageParams += "/OutputPath:$ProjectLocation\bin\$Configuration"
}
& "$SQLPackage" $SQLPackageParams