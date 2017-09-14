<#
.SYNOPSIS
Constructs headers and invokes the LM API as documented

.EXAMPLE
An example
    $Key = Read-Host -AsSecureString
    <Type your access key>
    Invoke-LMApi -Resource device/devices -Query @{size=100} -AccessId 'xpY57I5qB82YE9T79E3q' -AccessKey $Key -Company TDS
.EXAMPLE
Using file for storing key - will only run if everything is run as the same windows user.
    $Key = Read-Host -AsSecureString | Export-CLIxml -Path .\lmKey.xml
    <Type your access key>

    #Later, in a script
    $Key = Import-CliXml -Path .\lmKey.xml
    Invoke-LMApi -Resource device/devices -Query @{size=100} -AccessId 'xpY57I5qB82YE9T79E3q' -AccessKey $Key -Company TDS
.NOTES
If you use "Connect-lmAPI" first, other calls to this command will not need the connection info (company, accesskey and accessid)
All calls after the first in a script can forgo that information as well.
#>
function Invoke-lmAPI
{
    [CmdletBinding(DefaultParameterSetName='Normal')]
    Param (
        # The resource path to connect to
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Normal')]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Connect')]
        [String]
        $Resource,
        # The HTTP verb to use for this request
        [Parameter(ParameterSetName='Normal')]
        [Parameter(ParameterSetName='Connect')]
        [Alias("Verb")] 
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $HttpVerb ="Get",
        #AccessId for this API
        [Parameter(Mandatory=$true,ParameterSetName='Connect')]
        [String]
        $AccessId,
        #AccessKey for this API
        [Parameter(Mandatory=$true,ParameterSetName='Connect')]
        [SecureString]
        $AccessKey,
        #Company for this API
        [Parameter(Mandatory=$true,ParameterSetName='Connect')]
        [String]
        $Company,
        #Dictionary to be constructed into a QueryString
        [Parameter(ParameterSetName='Normal')]
        [Parameter(ParameterSetName='Connect')]
        [hashtable]
        $Query,
        #Body of the request
        [Parameter(ParameterSetName='Normal')]
        [Parameter(ParameterSetName='Connect')]
        [Object]
        $Body
        
    )
    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'Connect')
        {
            $Script:AccessId = $AccessId
            $Script:AccessKey = $AccessKey
            $Script:Company = $Company
            $Script:AccessKey.MakeReadOnly()
        }
    }
    process
    {   
        if ($Query)
        {
            $QueryString = ($Query.Keys | ForEach-Object {
                "{0}={1}" -f $_, $Query[$_]
            }) -join '&'
        }
        
        #Make sure resource is constructed '/path/path'
        $Resource = "/$($Resource.TrimStart('/'))"
        #construct the uri
        $URI = new-Object UriBuilder -Property @{
            Scheme = 'https://'
            Host   = "{0}.logicmonitor.com" -f $script:company
            Path   = "/santaba/rest{0}" -f $Resource
            Query  = $QueryString
        }

        $Epoch = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
        $requestVars = $httpVerb.ToString().ToUpper() + $epoch 
        if ($Body)
        {
            $requestVars += $Body
        }
        $requestVars += $Resource
        Write-Verbose -Message "RequestVars: $requestVars"
        <#
        Code for SecureString to String 
        https://blogs.msdn.microsoft.com/fpintos/2009/06/12/how-to-properly-convert-securestring-to-string/
        #>
        try {
            #Get a pointer to insecure string
            $unmanagedString = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($Script:AccessKey)
            #Compute hash using insecure string
            $hmac = New-Object System.Security.Cryptography.HMACSHA256
            $hmac.Key = [Text.Encoding]::UTF8.GetBytes(
                [System.Runtime.InteropServices.Marshal]::PtrToStringUni($unmanagedString)
            )
            $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        }
        finally {
            #Clean up the insecure stuff
            [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($unmanagedString)
            Remove-Variable unmanagedString -Force
            $hmac.Dispose()
        }
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        Write-Verbose -Message "HexSig: $signatureHex"
        $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))
        Write-Verbose -Message "Signature: $signature"
        $auth = 'LMv1 ' + $Script:accessId + ':' + $signature + ':' + $epoch
        Write-Verbose -Message "Auth: $auth"
        $Params = @{
            Uri = $URI.Uri
            Method = $HttpVerb
            UserAgent = "LM-{0}-PowerShell" -f $Script:Company
            Headers = @{
                Authorization = $auth
            }
            ContentType = 'application/json'
            Body = $Body
            #TimeoutSec
            #MaximumRedirection
            #TransferEncoding
        }
        try {
            $Response = Invoke-RestMethod @Params
            Write-Verbose "Status $($Response.status)"
            if ($Response.status -ne 200)
            {
                Write-Error -Message "Call to LM failed! $($Response.errmsg)" -ErrorId $Response.status
            }
        }
        Catch
        {
            Write-Error -Message ("LM API failure: {0}" -f $_.Exception.Message)
        }
    }
}