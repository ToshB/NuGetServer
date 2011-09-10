Import-Module (Resolve-Path .\packages\psake*\tools\psake.psm1)
Invoke-psake .\Build\default.ps1 $args
Remove-Module psake