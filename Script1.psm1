$ip = '192.168.197.114'

$base_api_uri = "https://$($ip)"
$baseuri = "https://$($ip)/redfish/v1"
$Managers = "$baseuri/Managers"

$Systems = "$baseuri/Systems"


$Chassis = "$baseuri/Chassis"

$Testnic = "$base_api_uri/redfish/v1/Systems/System.Embedded.1/EthernetInterfaces/NIC.Slot.4-4-1"

$Mysystem = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri $systems -Verbose -Credential $credentials).content | ConvertFrom-Json



$processors =  (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri/redfish/v1/Systems/System.Embedded.1/Processors/CPU.Socket.1" -Verbose -Credential $credentials).content | ConvertFrom-Json

$Storage = "/redfish/v1/Systems/System.Embedded.1/Storage/Controllers"
$Raidcontroller = "/redfish/v1/Systems/System.Embedded.1/Storage/Controllers/RAID.Integrated.1-1"

 (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri$Storage" -Verbose -Credential $credentials).content | ConvertFrom-Json


 $element = $Raidcontroller

 $outputobject = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri$element" -Verbose -Credential $credentials).content | ConvertFrom-Json



$Nics = "$base_api_uri"+($content.Content | ConvertFrom-Json).EthernetInterfaces.'@odata.id'

$embedded1 = "$base_api_uri/redfish/v1/Systems/System.Embedded.1"


$sessions = "$uri/v1/Sessions"

