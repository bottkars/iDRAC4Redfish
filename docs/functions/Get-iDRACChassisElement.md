# Get-iDRACChassisElement

Get-iDRACChassisElement retrieves Chassis Based odata information from iDRAC
```Powershell
NAME
    Get-iDRACChassisElement

SYNTAX
    Get-iDRACChassisElement [-iDRAC_Element <Object> {Power | Thermal}] [-WhatIf] [-Confirm]  [<CommonParameters>]
```
If no Parameter is specified, general Chassis Information is retrieved

```Powershell
Get-iDRACChassisElement


@odata.context : /redfish/v1/$metadata#Chassis.Chassis
@odata.id      : /redfish/v1/Chassis/System.Embedded.1
@odata.type    : #Chassis.v1_0_2.Chassis
Actions        : @{#Chassis.Reset=}
AssetTag       :
ChassisType    : Sled
Description    : It represents the properties for physical components for any system.It represent racks, rackmount
                 servers, blades, standalone, modular systems,enclosures, and all other containers.The non-cpu/device
                 centric parts of the schema are all accessed either directly or indirectly through this resource.
Id             : System.Embedded.1
IndicatorLED   : Off
Links          : @{ComputerSystems=System.Object[]; ComputerSystems@odata.count=1; ContainedBy=;
                 Contains=System.Object[]; Contains@odata.count=0; CooledBy=System.Object[]; CooledBy@odata.count=10;
                 ManagedBy=System.Object[]; ManagedBy@odata.count=1; PoweredBy=System.Object[];
                 PoweredBy@odata.count=2}
Manufacturer   : Dell Inc.
Model          : PowerEdge FC830
Name           : Computer System Chassis
PartNumber     : 0NNF5RX03
Power          : @{@odata.id=/redfish/v1/Chassis/System.Embedded.1/Power}
PowerState     : On
SKU            : 9G1FG42
SerialNumber   : CN701634C3004B
Status         : @{Health=Ok; HealthRollUp=Ok; State=Enabled}
Thermal        : @{@odata.id=/redfish/v1/Chassis/System.Embedded.1/Thermal}

@odata.context : /redfish/v1/$metadata#Chassis.Chassis
@odata.id      : /redfish/v1/Chassis/Chassis.Embedded.1
@odata.type    : #Chassis.v1_0_2.Chassis
AssetTag       :
ChassisType    : Rack
Description    : It represents the properties for physical components for any system.It represent racks, rackmount
                 servers, blades, standalone, modular systems,enclosures, and all other containers.The non-cpu/device
                 centric parts of the schema are all accessed either directly or indirectly through this resource.
Id             : Chassis.Embedded.1
IndicatorLED   :
Links          : @{ComputerSystems=System.Object[]; ComputerSystems@odata.count=0; Contains=System.Object[];
                 Contains@odata.count=1; CooledBy=System.Object[]; CooledBy@odata.count=10; ManagedBy=System.Object[];
                 ManagedBy@odata.count=0; PoweredBy=System.Object[]; PoweredBy@odata.count=2}
Manufacturer   : Dell Inc.
Model          : PowerEdge FX2s
Name           : CMC-FG1FG42
PartNumber     :
Power          : @{@odata.id=/redfish/v1/Chassis/Chassis.Embedded.1/Power}
PowerState     : On
SKU            :
SerialNumber   :
Status         : @{State=Enabled}
Thermal        : @{@odata.id=/redfish/v1/Chassis/Chassis.Embedded.1/Thermal}


```

The odata System has entities of Processors, SimpleStorage and EthernetInterfaces. They can be quries with

```Powershell
Get-iDRACChassisElement -iDRAC_Element Thermal
```

```Powershell
Get-iDRACChassisElement -iDRAC_Element Power
```

