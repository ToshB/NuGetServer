﻿Import-Module .\Build\teamcity.psm1

properties { 
	$BaseDir = Resolve-Path ".\"
	$SolutionFile = Resolve-Path $BaseDir\*.sln
	$OutputDir = "$BaseDir\Out\"
	$NuGetOutputDir = $OutputDir +"NuGet\"
	$TestAssemblies= @("*.Tests.Unit.dll","*.Tests.Integration.dll","*.Tests.dll")
	$NUnitPath = "$BaseDir\packages\NUnit.*\tools\nunit-console.exe"
	$NuGetPath = "$BaseDir\packages\NuGet.Commandline.*\tools\NuGet.exe"
} 

$framework = '4.0'

TaskSetup {
	$taskName = $currentContext.currentTaskName
	TeamCity-ProgressMessage("Executing task '$taskName'")
	TeamCity-StartBlock("$taskName")
}

TaskTearDown {
	$taskName = $currentContext.currentTaskName
	TeamCity-EndBlock("$taskName")
}

task default -depends Build

task Init {
	Write-Host $BaseDir
}

task Clean -depends Init {
    Remove-Item $OutputDir -recurse -force -ErrorAction SilentlyContinue
	Remove-Item $NuGetOutputDir -recurse -force -ErrorAction SilentlyContinue
	exec { msbuild /target:Clean /verbosity:minimal "$SolutionFile" }
} 

task Build -depends Clean{ 
	exec { msbuild /nologo /verbosity:minimal "$SolutionFile" "/p:OutDir=$OutputDir" }
} 

task Test -depends Build {
	$Tests = (Get-ChildItem "$OutputDir" -Recurse -Include $TestAssemblies)
	$NUnit = Resolve-Path $NUnitPath
	if(!$NUnit){
		throw "Could not find package NUnit at $NUnitPath, install with Install-Package NUnit"
	}
	if($Tests){
		$old = pwd
		cd $OutputDir
	  	& $NUnit /nologo $Tests
		TeamCity-ImportNUnitResult $OutputDir + "TestResult.xml"
		cd $old
	}else{
		Write-Host "Nothing to test ($TestAssemblies)"
	}
}

task PackNuget {
	Remove-Item $NuGetOutputDir -recurse -force -ErrorAction SilentlyContinue
	New-Item $NuGetOutputDir -ItemType directory | out-null
	$NuGet = Resolve-Path $NuGetPath
	if(!$NuGet){
		throw "Could not find package NuGet.CommandLine at $NuGetPath, install with Install-Package NuGet.CommandLine"
	}
	$specs = (Get-ChildItem "$BaseDir" -Recurse -Include "*.nuspec")
	foreach ($spec in $specs){
		$project = $spec.FullName.Replace("nuspec", "csproj")
		exec { & $NuGet pack $project -Build -Symbols -OutputDirectory $NuGetOutputDir -Properties Configuration=Release}
	}
	#publishing packages in nugetoutputdir
	foreach ($pkg in (Get-ChildItem $NuGetOutputDir -Recurse -Include *.nupkg)){
		TeamCity-PublishArtifact($pkg.FullName)
	}
}