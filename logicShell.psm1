Set-StrictMode -Version Latest

Get-ChildItem -Path $PSScriptRoot\functions -Filter '*.ps1' |
ForEach-Object {
    Write-Verbose "Running $($_.FullName)"
    . $_.FullName 
}
#Export-ModuleMember -Function Connect-lmApi,Invoke-lmApi,Get-lmDevice,Add-lmSdt