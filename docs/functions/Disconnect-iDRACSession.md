# Disconnect-iDRACSession

Disconnect-iDRACSession disconnects a / all idrac sessions
```Powershell
NAME
    Disconnect-iDRACSession

SYNTAX
    Disconnect-iDRACSession [-Session_Uri <Object>]  [<CommonParameters>]

    Disconnect-iDRACSession [-Session_ID <Object>]  [<CommonParameters>]
```

if no Parameter is specified, the current active iDRAC Session is disconnected

if all Sessions but current Sessions should be disconnected, use:

```Powershell
Get-iDRACSessions | where ID -notmatch $iDRAC_Session_ID  | Disconnect-iDRACSession
==> Calling delete /redfish/v1/Sessions/98 with Session 102
Successfully Completed Request
```
