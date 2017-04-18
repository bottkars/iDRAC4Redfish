# New-iDRACSession

New-iDRACSession connect´s to an iDRAC Controller ussing Session based Authentication

```Powershell
NAME
    New-iDRACSession

SYNTAX
    New-iDRACSession [-iDRAC_IP] <Object> [-iDRAC_Port <Object>] [-Credentials <pscredential>] [-trustCert]
    [<CommonParameters>]
```

Expected Parameters are 
* iDRAC_IP in the format xxx.xxx.xxx.xxx
if no PSCredentials object is specified, you will be prompted for Username and Password
