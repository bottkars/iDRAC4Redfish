# Get-iDRACSystemElement

Get-iDRACSystemElement retrieves System Based odata information from iDRAC
```Powershell
NAME
    Get-iDRACSystemElement

SYNTAX
    Get-iDRACSystemElement [-iDRAC_Element <Object> {Processors | SimpleStorage | EthernetInterfaces}] [-WhatIf]
    [-Confirm]  [<CommonParameters>]


```
If no Parameter is specified, general system Information is retrieved

```Powershell
~\Documents\GitHub\idrac4redfish [master =]> Get-iDRACSystemElement


@odata.context     : /redfish/v1/$metadata#ComputerSystem.ComputerSystem
@odata.id          : /redfish/v1/Systems/System.Embedded.1
@odata.type        : #ComputerSystem.v1_0_2.ComputerSystem
Actions            : @{#ComputerSystem.Reset=}
AssetTag           :
BiosVersion        : 2.3.5
Boot               : @{BootSourceOverrideEnabled=Once; BootSourceOverrideTarget=None;
                     BootSourceOverrideTarget@Redfish.AllowableValues=System.Object[]; UefiTargetBootSourceOverride=}
Description        : Computer System which represents a machine (physical or virtual) and the local resources such as
                     memory, cpu and other devices that can be accessed from that machine.
EthernetInterfaces : @{@odata.id=/redfish/v1/Systems/System.Embedded.1/EthernetInterfaces}
HostName           : PYFC830MAS.AzureStack.Local
Id                 : System.Embedded.1
IndicatorLED       : Off
Links              : @{Chassis=System.Object[]; Chassis@odata.count=1; CooledBy=System.Object[];
                     CooledBy@odata.count=10; ManagedBy=System.Object[]; ManagedBy@odata.count=1;
                     PoweredBy=System.Object[]; PoweredBy@odata.count=2}
Manufacturer       : Dell Inc.
MemorySummary      : @{Status=; TotalSystemMemoryGiB=192,0}
Model              : PowerEdge FC830
Name               : System
PartNumber         : 0NNF5RX03
PowerState         : On
ProcessorSummary   : @{Count=4; Model=Intel(R) Xeon(R) CPU E5-4650 v3 @ 2.10GHz; Status=}
Processors         : @{@odata.id=/redfish/v1/Systems/System.Embedded.1/Processors}
SKU                : 9G1FG42
SerialNumber       : CN701634C3004B
SimpleStorage      : @{@odata.id=/redfish/v1/Systems/System.Embedded.1/Storage/Controllers}
Status             : @{Health=OK; HealthRollUp=OK; State=Enabled}
SystemType         : Physical
UUID               : 4c4c4544-0047-3110-8046-b9c04f473432


```

The odata System has entities of Processors, SimpleStorage and EthernetInterfaces. They can be quries with

```Powershell
Get-iDRACSystemElement -iDRAC_Element EthernetInterfaces
```

```Powershell
Get-iDRACSystemElement -iDRAC_Element Processors
```
```Powershell
Get-iDRACSystemElement -iDRAC_Element SimpleStorage
```
