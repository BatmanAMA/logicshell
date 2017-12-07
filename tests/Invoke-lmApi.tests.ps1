#Requires -modules Pester
Remove-Module -name logicshell -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../LogicShell.psd1
Describe Invoke-lmAPI {
    Connect-lmAPI -AccessId Test -Company Test  -AccessKey (ConvertTo-SecureString -String "Test" -AsPlainText -Force)

    Context Success {
        $Epoch = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
        $requestVars = "POST$($Epoch)TestDataStuff/Things"
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [Text.Encoding]::UTF8.GetBytes("Test")
        $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))
        $auth = 'LMv1 ' + "Test" + ':' + $signature + ':' + $epoch
        $builder = new-Object UriBuilder -Property @{
            Scheme = 'https://'
            Host   = "{0}.logicmonitor.com" -f "Test"
            Path   = "/santaba/rest/stuff/things"
            Query  = "test=True"
        }
        Mock Invoke-RestMethod -ModuleName logicshell -MockWith {
            New-Object psobject -Property @{Status = 200}
        } -ParameterFilter {
            $Uri -eq $builder.Uri
            $Method -eq "Post"
            $UserAgent -eq "LM-Test-PowerShell"
            $Headers -eq @{
                Authorization = $auth
            }
            $ContentType -eq 'application/json'
            $Body -eq "TestData"
        }
        it "doesn't Error" {
            {Invoke-lmAPI -Resource stuff/things -HttpVerb Post -Query @{"test" = "True"} -Body "TestData"} | 
                Should -Not -Throw
        }
        it "calls the restmethod" {
            Assert-VerifiableMock
        }
    }
    Context httpFailure {
        Mock Invoke-RestMethod -ModuleName logicshell -MockWith {
            New-Object psobject -Property @{Status = 201; errmsg = "test"}
        }
        it "errors out when logic monitor doesn't return 200" {
            {Invoke-lmAPI -Resource stuff/things -ErrorAction Stop} | 
                Should -Throw
        }
    }
    Context Other_Failure {
        it "errors out when HTTP fails" {
            {Invoke-lmAPI -Resource stuff/things -ErrorAction Stop} | 
                Should -Throw
        }
    }
    Context Other_Failure {
        Mock Invoke-RestMethod -ModuleName logicshell -MockWith {
            New-Object psobject -Property @{Status = 200; }
        }
        Invoke-lmAPI -Resource stuff/things -Company 'incommand' -AccessId 'incommand' -AccessKey (ConvertTo-SecureString -String "Test" -AsPlainText -Force) | 
            Out-Null
        it "Connects when told to do so" {
            $Script:AccessId -eq "incommand" -and
            $Script:Company -eq "incommand" -and 
            $Script:AccessKey -isnot $null -and
            $Script:AccessKey.IsReadOnly()
        }
    }
}