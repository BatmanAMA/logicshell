<#
.SYNOPSIS
    Get devices from logicmonitor
.DESCRIPTION
    Implements device/devices endpoint from the logicmonitor API
.EXAMPLE
    Get-lmDevice
    #Returns all logicmonitor devices
.EXAMPLE
    Get-lmDevice -filter '*dc*'
    #returns all LogicMonitor Devices with DC in the name
#>
function Get-lmDevice {
    [CmdletBinding()]
    Param (
        <# 
        Device Filter using LogicMonitors filter spec:
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
        [Parameter(Position=0)]
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
    
    begin {
    }
    
    process {
        $QueryParm = @{size=$ItemLimit}
        if ($Filter.Count -gt 0)
        {
            $FilterString = $Filter -join ','
            $QueryParm['filter'] =$FilterString
        }
        if ($Sort.Length -gt 0)
        {
            $QueryParm['sort'] =$Sort
        }
        if ($Field.Count -gt 0)
        {
            $FieldString = $Field -join ','
            $QueryParm['fields'] =$FieldString
        }
        $toReturn = Invoke-LMApi -Resource device/devices -Query $QueryParm
        $items = $toReturn.data.items
        while ($toReturn.data.total -gt $items.Count)
        {
            $QueryParm['offset'] = $items.count
            $toReturn = Invoke-LMApi -Resource device/devices -Query $QueryParm
            $items += $toReturn.data.items
        }
        $items
    }
}