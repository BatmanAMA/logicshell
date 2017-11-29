<#
.SYNOPSIS
Connects to the logicmonitor api for the other LM module commands

.DESCRIPTION
This command saves the relevant information to be able to use the other LogicMonitor commands from this module without having to re-auth

.EXAMPLE
$Pass = Read-Host -AsSecureString
>>Y2SSbf7aD7te~)9MYiMR~](32P7T%s^^Fi6AS6RG

Connect-lmAPI -Company Contoso -AccessId a1093019affd -AccessKey $pass

.NOTES
General notes
#>
function Connect-lmAPI
{
    param(
        #AccessId for this API
        [Parameter(Mandatory = $true)]
        [String]
        $AccessId,
        #AccessKey for this API
        [Parameter(Mandatory = $true)]
        [SecureString]
        $AccessKey,
        #Company for this API
        [Parameter(Mandatory = $true)]
        [String]
        $Company
    )
    process
    {
        $Script:AccessId = $AccessId
        $Script:AccessKey = $AccessKey
        $Script:Company = $Company
        $Script:AccessKey.MakeReadOnly()
    }
}
