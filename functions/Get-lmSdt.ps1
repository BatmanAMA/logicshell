
<#
.SYNOPSIS
    Gets scheduled downtime by device, user or time
.DESCRIPTION
    This command implements the GET method of the logicmonitor API
.EXAMPLE
    #Puts the device named "CORP-DC01" in Scheduled Downtime for the next 3 hours
    Add-lmSdt -Type Device -Name CORP-DC01 -StartTime (Get-Date) -EndTime ((Get-Date).AddHours(3)) -Comment "DC is acting up, rebooting and running some diagnostics"
.EXAMPLE
    #Puts a device in SDT by id for 3 hours at midnight the first of next month.
    Add-lmSdt -Type Device -Id 966 -StartTime (Get-Date -day 1 -Hour 0 -minute 0 -second 0).AddMonths(1) -EndTime (Get-Date -day 1 -Hour 3 -minute 0 -second 0).AddMonths(1)
.NOTES
    LogicMonitor cares about capitalization, if it really matters, use ID.
#>
function Get-lmSdt
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param (
        <# 
        Filter using LogicMonitors filter spec:
        property{operator}value 
        Uses wild card char "*"
        where operator is one of:
            Greater than or equals: >:
            Less than or equals:    <:
            Greater than:           >
            Less than:              <
            Does not equal:         !:
            Equals:                 :
            Includes:               ~
            Does not include:       :
        #>
        [Parameter(Position = 0)]
        [String[]]
        $Filter,
        
        # Sort by a property (+property or -property)
        [String]
        $Sort,
        
        # Limit the returned fields
        [Alias('Property')]
        [String[]]
        $Field,

        #Number of items to retrieve per call (for rate limiting)
        [int]
        $ItemLimit = 500
    )
    process
    {

        $QueryParm = @{size = $ItemLimit}
        if (@($Filter).Count -gt 0)
        {
            $FilterString = $Filter -join ','
            $QueryParm['filter'] = $FilterString
        }
        if ($Sort.Length -gt 0)
        {
            $QueryParm['sort'] = $Sort
        }
        if (@($Field).Count -gt 0)
        {
            $FieldString = $Field -join ','
            $QueryParm['fields'] = $FieldString
        }
        $toReturn = Invoke-LMApi -Resource sdt/sdts -Query $QueryParm
        $items = $toReturn.data.items
        while ($toReturn.data.total -gt @($items).Count)
        {
            try
            {
                $QueryParm['searchid'] = $toReturn.searchid
            }
            catch 
            {
                Write-Error "no searchid in the returned data" -ErrorAction "SilentlyContinue"
            }
            $QueryParm['offset'] = $items.count
            $toReturn = Invoke-LMApi -Resource sdt/sdts -Query $QueryParm
            $items += $toReturn.data.items
        }
        $items
    }
}