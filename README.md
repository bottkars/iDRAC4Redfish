# iDRAC4Redfish
| Branch | AppVeyor |
| ------ | -------- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/7ft0dny2738lli8s/branch/master?svg=true)](https://ci.appveyor.com/project/bottkars/idrac4redfish)

iDRAC4Redfish is a opensource implementation of Powershell modules using Redfish / odata access to DELL|EMC Servers vi iDRAC.

![image](https://cloud.githubusercontent.com/assets/8255007/24893639/317f771e-1e85-11e7-807f-9afcc484ad3a.png)![image](https://cloud.githubusercontent.com/assets/8255007/24893670/7d10c714-1e85-11e7-959d-faf7243605a1.png)


This current WIP is used for demo purposes, monitoring and Test
Configuration for Cloning and Deployments are planned as well

# getting started
install the modules in powershell using 
```Powershell
install-module iDRAC4redfish
```

then, connect to your iDRAC. There are two way´s to connect to the iDRAC System :
* USING Basic Auth 
* Using Session Based Auth
Session Based auth log´s in once to get a Session X-AUTH-Token, an from there on uses this token

```Powershell
New-iDRACSession -iDRAC_IP  172.16.6.151
```
![image](https://cloud.githubusercontent.com/assets/8255007/24998506/a256f0d2-203a-11e7-85d5-7185d712e599.png)

@azurestack_guy. April 2017
