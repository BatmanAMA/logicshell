<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function Connect-lmAPI
{
    param(
        #AccessId for this API
        [Parameter(Mandatory=$true)]
        [String]
        $AccessId,
        #AccessKey for this API
        [Parameter(Mandatory=$true)]
        [SecureString]
        $AccessKey,
        #Company for this API
        [Parameter(Mandatory=$true)]
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
