Set-IDRACAccount allows for changing / Adding Idrac Users
## create a user

```Powershell
Set-iDRACAccount -AccountID 6 -username test3 -Role Operator
Cmdlet Set-iDRACAccount an der Befehlspipelineposition 1
Geben Sie Werte für die folgenden Parameter an:
User_Password: ************
Successfully Completed Request
```

## change password for user 4
this command uses pipelining from Get-IDRACAccounts -Account
```Powershell
Get-iDRACAccounts -AccountID 4 -Verbose | Set-iDRACAccount
Cmdlet Set-iDRACAccount an der Befehlspipelineposition 2
Geben Sie Werte für die folgenden Parameter an:
User_Password: ************
VERBOSE: ==> getting elements for odata Link /redfish/v1/Managers/iDRAC.Embedded.1/Accounts/4
VERBOSE: ==> Calling https://10.204.86.121:443/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/4 with Session 5
VERBOSE: GET https://10.204.86.121/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/4 with 0-byte payload
VERBOSE: received 422-byte response of content type application/json;odata.metadata=minimal;charset=utf-8
Successfully Completed Request
```
