# Get-iDRACodata


Get-iDRACodata is Metafunction to retrieve JSON Data from odata links

This example retrieves the odata link for simple Storage from the Get-iDRACSystemElement function:

```Powershell
(Get-iDRACSystemElement).SimpleStorage
``` 
The result as displayed :
``` 
@odata.id
---------
/redfish/v1/Systems/System.Embedded.1/Storage/Controllers
``` 

we can now use the displayed @odata.id object to pipe it into Get-iDRACodata

```Powershell
(Get-iDRACSystemElement).SimpleStorage | Get-iDRACodata
```

Result:

```
@odata.context      : /redfish/v1/$metadata#SimpleStorageCollection.SimpleStorageCollection
@odata.id           : /redfish/v1/Systems/System.Embedded.1/Storage/Controllers
@odata.type         : #SimpleStorageCollection.SimpleStorageCollection
Description         : Collection of Controllers for this system
Members             : {@{@odata.id=/redfish/v1/Systems/System.Embedded.1/Storage/Controllers/RAID.Integrated.1-1},
                      @{@odata.id=/redfish/v1/Systems/System.Embedded.1/Storage/Controllers/RAID.Modular.3-1},
                      @{@odata.id=/redfish/v1/Systems/System.Embedded.1/Storage/Controllers/AHCI.Embedded.1-1},
                      @{@odata.id=/redfish/v1/Systems/System.Embedded.1/Storage/Controllers/AHCI.Embedded.2-1}}
Members@odata.count : 4
Name                : Simple Storage Collection
```
