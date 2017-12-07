#Requires -modules Pester
Remove-Module -name logicshell -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../LogicShell.psd1
Describe Add-lmSDT {
    Connect-lmAPI -AccessId Test -Company Test  -AccessKey (ConvertTo-SecureString -String "Test" -AsPlainText -Force)
    Context DeviceID {
        $Start = [System.DateTimeOffset]::Now
        $end = $start.AddHours(3)
        Mock Invoke-lmAPI -ModuleName logicshell -Verifiable -MockWith {} -ParameterFilter {
            $Type -eq "Device"
            $Id -eq 0
            $StartTime -eq $start
            $EndTime -eq $end
            $Comment -eq "Testing the script"
        }
        Add-lmSdt -Type Device -Id 0 -StartTime $start -EndTime $end -Comment "Testing the script"
        It "calls LogicMonitor API" {
            Assert-VerifiableMock
        }
    }
    Context DeviceName {
        $Start = [System.DateTimeOffset]::Now
        $end = $start.AddHours(3)
        Mock Invoke-lmAPI -ModuleName logicshell -Verifiable -MockWith {} -ParameterFilter {
            $Type -eq "Device"
            $Name -eq "Test"
            $StartTime -eq $start
            $EndTime -eq $end
            $Comment -eq "Testing the script"
        }
        Add-lmSdt -Type Device -Name Test -StartTime $start -EndTime $end -Comment "Testing the script"
        It "calls LogicMonitor API" {
            Assert-VerifiableMock
        }
    }
}
