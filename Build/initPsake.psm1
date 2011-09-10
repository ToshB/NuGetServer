function Invoke-psake($arguments)
{
	$psake = 
	if(!$psake){
		Write-Host "Could not locate psake in packages dir, make sure it is installed"
		return;
	}
	Import-Module Resolve-Path .\packages\psake*\tools\psake.psm1
	Invoke-psake .\Build\default.ps1 $arguments
	Remove-Module psake
}

Export-ModuleMember Use-psake
