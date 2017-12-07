#Requires -modules Pester
Remove-Module -name logicshell -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../LogicShell.psd1
Describe Get-lmSdt {
    Connect-lmAPI -AccessId Test -Company Test  -AccessKey (ConvertTo-SecureString -String "Test" -AsPlainText -Force)


    $QueryParm = @{
        size   = 500
        filter = "Name:*TEST*,Test:True"
        sort   = "Id"
        fields = "Test,Name"
    }
    Mock Invoke-lmAPI -ModuleName logicshell -Verifiable -MockWith {
        New-Object psobject -Property @{
            data = (
                New-Object psobject -Property @{
                    items = @()
                    total = 0
                }
            )
        }
    } -ParameterFilter {
        $Resource -eq 'sdt/sdts'
        $Query -eq $QueryParm
    }
    it "Should not throw" {
        {Get-lmSdt -Filter @("Name:*TEST*", "Test:True") -Sort "Id" -Field @("Test", "Name") -ItemLimit 500} |
            Should -not -throw
    }
    it "Should call invoke-lmapi" {
        Assert-VerifiableMock
    }
}