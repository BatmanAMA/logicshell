![](./logicshell.png)
# LogicShell
A simple PowerShell wrapper for LogicMonitor!

This module is feature complete using just "invoke-lmApi" - all other commands are just there as helper functions to make it a little easier.

# Some Examples

## Initial Setup

Imagine this is run before the other examples

```powershell
#First set up the key as a secure string
$key = Read-Host -asSecureString
>*********************************
#Now, we'll set up the environment so the other commands can run without having to constantly specify the environmental stuff
Connect-lmAPI -Company Contoso -AccessId xpY57I5qB82YE9T79E3q -AccessKey $Key
```

## Get-lmDevice
```powershell
#Get machines with dc in the name and an environment of production
Get-lmDevice -filter 'name~*dc*','environment:production'

#Get just device Names and ID
$List = Get-lmDevice -Field name,id
```
## Add-lmSdt
```powershell
#Add a Scheduled Downtime for corp-dc01 in a few years
Add-lmSdt -Type Device -Name corp-dc01 -StartTime (Get-Date '1/1/2048 0:0:0') -EndTime (Get-Date '1/1/2048 3:0:0')
#Add SDT for a list of devices (from example above)
$list | foreach-object {Add-lmSdt -Type Device -id $_.id -StartTime (Get-Date) -EndTime (Get-Date).AddHours(5)}
```

## Invoke-lmApi
```powershell
# Adding an opsnote to device id 932
$body = @{
    note="Testing Opsnote via API"
    scopes=@{
        @{
            type="device"
            id=932
        }
    }
    tags=@{
        @{
            name="test"
        },
        @{
            name="api"
        }
    }
} | ConvertTo-Json -compress
Invoke-LMApi -Resource setting/opsnotes -Body $body -HttpVerb POST
```