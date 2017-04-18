# iDRAC4Redfish
| Branch | AppVeyor |
| ------ | -------- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/7ft0dny2738lli8s/branch/master?svg=true)](https://ci.appveyor.com/project/bottkars/idrac4redfish)

iDRAC4Redfish is a open Implementation of Powershell modules using Redfish / odata access to DELL|EMC Servers via iDRAC.

![image](https://cloud.githubusercontent.com/assets/8255007/24893639/317f771e-1e85-11e7-807f-9afcc484ad3a.png)![image](https://cloud.githubusercontent.com/assets/8255007/24893670/7d10c714-1e85-11e7-959d-faf7243605a1.png)


This current WIP is used for demo purposes, monitoring and test
Configuration for Cloning and deployment is planned as well

# getting started
install the modules in powershell using 
```Powershell
install-module iDRAC4redfish
```

then, connect to your iDRAC. There are two way´s to connect to the iDRAC System :
* Using Basic Auth 
* Using Session Based Auth  
Session Based Authentication logs into iDRAG once to get a Session X-AUTH-Token, an from there on the received X-Auth-Token is used. 

```Powershell
New-iDRACSession -iDRAC_IP  172.16.6.151
```
![image](https://cloud.githubusercontent.com/assets/8255007/24998506/a256f0d2-203a-11e7-85d5-7185d712e599.png)

Once connected, you may want to use some basic commands:
# Browse the system Elements:

```Powershell
Get-iDRACSystemElement
```
This lists all entities of the System Object:
![image](https://cloud.githubusercontent.com/assets/8255007/24998676/3e90086c-203b-11e7-895c-fa0863d08ca4.png)

To get more details on System Elements, you may Specify the Elements by -iDRAC_Element:
```Powershell
Get-iDRACSystemElement -iDRAC_Element Storage/Controllers
```  

![image](https://cloud.githubusercontent.com/assets/8255007/24998761/899e6380-203b-11e7-86af-e9b34ba8acab.png)

You may narrow down to specific Objects like Devices of type Storage/Controllers by
```Powershell
Get-iDRACSystemElement -iDRAC_Element Storage/Controllers | Select-Object -ExpandProperty Devices
```

![image](https://cloud.githubusercontent.com/assets/8255007/24998900/eccf2296-203b-11e7-929b-f166fc9afc35.png)

# Session Management
To get a list of iDRAC Sessions, use
```Powershell
Get-iDRACSessions
```
![image](https://cloud.githubusercontent.com/assets/8255007/25011629/515984c2-206e-11e7-9c2d-b29971adb9c7.png)

to Disconnect a specific Session

```Powershell
Disconnect-iDRACSession -Session_ID 82
```
![image](https://cloud.githubusercontent.com/assets/8255007/25011729/aa453572-206e-11e7-9555-557966f4a722.png)

To diconnect the current session

```Powershell
Disconnect-iDRACSession
```
![image](https://cloud.githubusercontent.com/assets/8255007/25012052/94c2261e-206f-11e7-8b18-fe0705e23840.png)

# Copy System Configuration Profiles for Cloning
```Powershell
Copy-iDRACSCP -Credentials $credential -Cifs_IP 172.21.1.103 -Cifs_Sharename dscfra -Filename export3.xml -waitcomplete
```
![image](https://cloud.githubusercontent.com/assets/8255007/25037685/d52e68c6-20fa-11e7-9b8c-8a56a273f0a5.png)

@azurestack_guy. April 2017
