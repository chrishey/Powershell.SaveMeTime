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