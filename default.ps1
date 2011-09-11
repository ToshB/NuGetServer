# psake .\default.ps1 build -parameters @{Whatif=1}

Import-Module .\Build\common.ps1

task SolutionSpecific -depends Init {
	Write-Host "I could be replaced with a task doing something solution specific"
}