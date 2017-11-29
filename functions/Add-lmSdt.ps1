
<#
.SYNOPSIS
    Adds a scheduled downtime to a thing
.DESCRIPTION
    Pop pop
.EXAMPLE
    #Puts the device named "CORP-DC01" in Scheduled Downtime for the next 3 hours
    Add-lmSdt -Type Device -Name CORP-DC01 -StartTime (Get-Date) -EndTime ((Get-Date).AddHours(3)) -Comment "DC is acting up, rebooting and running some diagnostics"
.EXAMPLE
    #Puts a device in SDT by id for 3 hours at midnight the first of next month.
    Add-lmSdt -Type Device -Id 966 -StartTime (Get-Date -day 1 -Hour 0 -minute 0 -second 0).AddMonths(1) -EndTime (Get-Date -day 1 -Hour 3 -minute 0 -second 0).AddMonths(1)
.NOTES
    LogicMonitor cares about capitalization, if it really matters, use ID.
#>
function Add-lmSdt 
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param (
        #What object you will schedule SDT for
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "Service",
            "ServiceGroup",
            "Device",
            "Collector",
            "DeviceBatchJob",
            "DeviceDataSource",
            "DeviceEventSource",
            "DeviceDataSourceInstance",
            "DeviceDataSourceInstanceGroup"
        )]
        [String]
        $Type,
        #ID of the thing to schedule downtime for
        [Parameter(Mandatory = $true, ParameterSetName = "id")]
        [int]
        $Id,
        #Name of the thing to schedule downtime for
        [Parameter(Mandatory = $true, ParameterSetName = "name")]
        [String]
        $Name,
        #What time the SDT should start
        [Parameter(Mandatory = $true)]
        [DateTimeOffset]
        $StartTime,
        #What time the SDT should start
        [Parameter(Mandatory = $true)]
        [DateTimeOffset]
        $EndTime,
        #A comment to include (Recommended)
        [String]
        $Comment
    )
    process
    {

        $data = New-Object psobject -Property @{
            sdtType       = 1
            type          = "{0}SDT" -f $Type
            startDateTime = $StartTime.ToUnixTimeMilliseconds()
            endDateTime   = $EndTime.ToUnixTimeMilliseconds()
            comment       = $Comment
        }
        if ($PSCmdlet.ParameterSetName -eq 'id')
        {
            $idProp = "{0}Id" -f $Type
            #fix capitalization
            $idProp = $idProp.Substring(0, 1).ToLower() + $idProp.Substring(1)
            $data | Add-Member -NotePropertyName $idProp -NotePropertyValue $Id
        }
        if ($PSCmdlet.ParameterSetName -eq 'name')
        {
            $nameProp = "{0}Name" -f $type
            #fix capitalization
            $nameProp = $nameProp.Substring(0, 1).ToLower() + $nameProp.Substring(1)
            $data | Add-Member -NotePropertyName $nameProp -NotePropertyValue $Name
        }
        $data = $data | ConvertTo-Json -Compress
        Invoke-lmAPI -Resource sdt/sdts -HttpVerb Post -body $data
    }
}