function OpenVSSolution($project){
	# append the project path to the environment variable for my git repos
	$r=$env:GitRepos;
	$r+=$project;
	
	# find the sln file
	$f=Get-FileWithCriteria -extension ".sln" -repo $r;
		
	# open it
	Open-File $f;
}