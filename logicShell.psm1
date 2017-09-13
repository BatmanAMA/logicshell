Set-StrictMode -Version Latest

Get-ChildItem -Path $PSScriptRoot\functions -Filter '*.ps1' |
ForEach-Object {
    Write-Verbose "Running $($_.FullName)"
    . $_.FullName 
}
Export-ModuleMember -Function Connect-lmApi,Invoke-lmApi,Get-lmDevice,Add-lmSdt

# xpY57I5qB82YE9T79E3q
# 67+Ki~4nwR2]$FaFqiVimR3-8j[[F(db8^3K5(t=