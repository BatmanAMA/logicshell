#Requires -modules Pester
Remove-Module -name logicshell -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../LogicShell.psd1
Describe Connect-lmAPI {
    Connect-lmAPI -AccessId Test -Company Test  -AccessKey (ConvertTo-SecureString -String "Test" -AsPlainText -Force)
    It 'should set script variables' {
        $Script:AccessId -eq "Test" -and
        $Script:Company -eq "Test" -and 
        $Script:AccessKey -isnot $null -and
        $Script:AccessKey.IsReadOnly()
    }
}