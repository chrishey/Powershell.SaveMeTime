<# 
	.SYNOPSIS
		Sets a user environment variable 

	.DESCRIPTION
		This function sets a user environment variable on the local machine. This variable will only be available to the logged in user

	.PARAMETER  Name
		The name of the variable

	.PARAMETER  Value
		The value of the variable you have set.

	.EXAMPLE
		PS C:\> Set-UserEnvironmentVariable  casesFolder "C:\MyCases"

	.INPUTS
		System.String,System.String

	.OUTPUTS
		System.String

	.NOTES
		To override the value of an existing variable, call the function again, supplying the variable name and the new value .
		To remove the environment variable call the function again, supplying the variable name and $null as the value.
	
#>
function Set-UserEnvironmentVariable($name, $value){
	[Environment]::SetEnvironmentVariable("$name",$value,"User")
}

<#
	.SYNOPSIS
		Find a file in a folder or repo by filename and extension
		
	.DESCRIPTION
		The function will recursively go through the given folder to find the file, return null if it is unable to find the file in the folder and its children
		
	.PARAMETER Name
		Name of the file minus the extension
		
	.PARAMETER Extension
		File extension to look for
		
	.PARAMETER Repo
		Folder or repository to start looking in for the file
		
	.EXAMPLE
		PS C:\> Get-FileWithCriteria helloworld txt C:\Temp
	
	.INPUTS
		System.String,System.String,System.String
		
	.OUTPUTS
		System.String

#>

function Get-FileWithCriteria(){
	param(
		[Parameter(Mandatory=$false)] $name,
		[Parameter(Mandatory=$true)] $extension,
		[Parameter(Mandatory=$true)] $repo
	)
	if($name -eq $null){
		$filePath = "*"
		$filePath+=$extension
		$file = Get-ChildItem . -Include $filePath -Path $repo -Recurse
	}
	if($file -eq $null) {
		$filePath = $name
		$filePath+=$extension
		$file = Get-ChildItem . -Include "*$name.$extension" -Path $repo -Recurse
	}
	if($file -eq $null) {
		Write-Host "Unable to find file $name.$extension in $repo" -foregroundcolor "magenta";
		return $null;
	}
	
	return $file;
}

function Open-File($file){
	Invoke-Item $file;
}

function Pull-Repo($repo){
	try{
		Push-Location $repo
		git pull
	}
	catch [System.ItemNotFoundException]{
		# git clone
	}
}

<#
	.SYNOPSIS
		Extract a compressed file (if an association can be made) to a folder
		
	.DESCRIPTION
		Pass in the location of the compressed file and he folder you wish to extract the contents to
		
	.PARAMETER File
		Location of the compressed file
		
	.PARAMETER Destination
		Folder you want the contents of the compressed file to go to
		
	.EXAMPLE
		PS C:\> ExtractZipFile C:\Test.zip C:\Temp
	
	.INPUTS
		System.String,System.String
		
	.OUTPUTS
		No return type

#>
function ExtractZipFile($file, $destination)
{
	$shell = New-Object -Com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items())
	{
		$shell.NameSpace($destination).copyhere($item)
	}
}

<#
	.SYNOPSIS
		Check if a site or app pool exists in IIS
	.DESCRIPTION
		Pass in a name of an app pool or site and get a true/false result if it exists in IIS
	.PARAMETER Name
		App pool or site name
	.EXAMPLE
		PS C:\> CheckExistsInIIS TestSite
	.INPUTS
		System.String
	.OUTPUTS
		Boolean, true if exists
#>
function CheckExistsInIIS($name)
{
	return Test-Path $name -PathType Container
}

<#
	.SYNOPSIS
		List of virtual directories for a site
	.DESCRIPTION
		Pass in the name of the site and virtual directory and get a list response
	.PARAMETER Name
		Virtual Directory name
	.PARAMETER Site
		Site name
	.EXAMPLE
		PS C:\> ListVirtualDirectories test TestSite
	.INPUTS
		System.String, System.String
	.OUTPUTS
		List of virtual directories
#>
function ListVirtualDirectories($name, $site)
{
	return Get-WebVirtualDirectory -Site $site -Name $name
}

function CheckVirtualDirectoryExists($name, $site)
{
	$list = ListVirtualDirectories $name $site
	if($list -eq $null)
	{
		return $false
	}
	
	return $true
}

function CreateAppPool($name, $dotNetVersion)
{
	cd IIS:\AppPools\
	
	try
	{
		$appPool = New-Item $name
		$appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $dotNetVersion
		return $true
	}
	catch
	{
		Write-Host "Failed to create app pool" $name "using .NET version" $dotNetVersion
		return $false
	}
}

function CreateWebSite($name, $directory, $appPool)
{
	cd IIS:\Sites\
	
	try
	{
		$iisApp = New-Item $name -bindings @{protocol="http";bindingInformation=":80:" + $name} -physicalPath $directory
		$iisApp | Set-ItemProperty -Name "applicationPool" -Value $appPool
		return $true
	}
	catch
	{
		Write-Host "Failed to create a site" $name "in" $directory "using app pool" $appPool
		return $false
	}
}

<#
	.SYNOPSIS
		Create a virtual directory on a site to point to a directory
	.DESCRIPTION
		Pass in the name of the virtual directory that needs creating on the specified site, pointing at the specified directory
	.PARAMETER Name
		Name of the virtual directory
	.PARAMETER Site
		Name of the site to create the virtual directory on
	.PARAMETER Directory
		Location of the directory for the virtual directory to point at
	.EXAMPLE
		PS C:\> CreateVirtualDirectory test TestSite C:\Temp\
	.INPUTS
		System.String, System.String, System.String
	.OUTPUTS
		No return type
		
#>
function CreateVirtualDirectory($name, $site, $directory)
{
	cd IIS:\
	
	try
	{
		$path = 'IIS:\Sites\'
		$path += $site
		$path += '\'
		$path += $name
		New-Item $path -type VirtualDirectory -physicalPath $directory
		return $true
	}
	catch
	{
		Write-Host $Error
		return $false
	}
}