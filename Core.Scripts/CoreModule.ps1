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
	

#>

function Get-FileWithCriteria($name, $extension, $repo){
	$file = Get-ChildItem . -Include "*$name.$extension" -Path $repo -Recurse
	if($file -eq $null) {
		Write-Host "Unable to find patch $name.$extension in $repo" -foregroundcolor "magenta";
		return $null;
	} 
}