$oldDir = $pwd
cd (Split-Path -Parent $MyInvocation.MyCommand.Definition)
Import-Module (Resolve-Path .\packages\psake*\tools\psake.psm1)
Invoke-psake .\default.ps1 $args
Remove-Module psake
cd $oldDir