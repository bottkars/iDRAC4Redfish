# 192.168.197.114 root calvin
function Unblock-Certs
{
    Add-Type -TypeDefinition @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy

}


(Invoke-WebRequest -UseBasicParsing "$baseuri/odata" -Credential $credentials -ContentType 'Application/Json').content | ConvertFrom-Json | select -ExpandProperty value

function Connect-iDRAC
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $iDRAC_IP = "192.168.2.193",
        $iDRAC_Port = 443,
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   Position=0)][pscredential]$Credentials,
        [switch]$trustCert
    )
    Begin
    {
    if ($trustCert.IsPresent)
        {
        Unblock-Certs
        }
	#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    }
    Process
    {
    if (!$Credentials)
        {
        $User = Read-Host -Prompt "Please Enter iDRAC username"
        $SecurePassword = Read-Host -Prompt "Enter iDRAC Password for user $user" -AsSecureString
        $Credentials = New-Object System.Management.Automation.PSCredential (“$user”,$Securepassword)
        }
    write-Verbose "Generating Login Token"
    $Global:iDRAC_baseurl = "https://$($iDRAC_IP):$iDRAC_Port/redfish/v1" # :$iDRAC_Port"
    $Global:iDRAC_Credentials = $Credentials
    Write-Verbose $idrac_baseurl
    try
        {
        $Schemas = (Invoke-WebRequest -UseBasicParsing "$Global:iDRAC_baseurl/odata" -Credential $credentials -ContentType 'Application/Json').content | ConvertFrom-Json | select -ExpandProperty value

        }
    catch [System.Net.WebException]
        {
        # Write-Warning $_.Exception.Message
        #Get-SIOWebException -ExceptionMessage $_.Exception.Message
		Write-Host "to be defined"
        Write-Verbose $_
        Write-Warning $_.Exception.Message
        Break
        }
    catch
        {
        Write-Verbose $_
        Write-Warning $_.Exception.Message
        break
        }
        #>
        Write-Host "Successfully connected to iDRac with IP $iDRAC_IP"
        Write-Host " we got the following Schemas: "
        $Schemas
    }
    End
    {
    }
}




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


function Get-iDRACManagerUri
{
 $outputobject = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri $Managers -Verbose -Credential $credentials).content | ConvertFrom-Json

 $Global:iDRAC_Manager = "$base_api_uri$($outputobject.Members.'@odata.id')"
 Write-Host -ForegroundColor Green "==> Gota manager at $Global:iDRAC_Manager"
}


function Get-iDRACSystemUri
{
 $outputobject = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri $Systems -Verbose -Credential $credentials).content | ConvertFrom-Json

 $Global:iDRAC_System = "$base_api_uri$($outputobject.Members.'@odata.id')"
 Write-Host -ForegroundColor Green "==> Gota manager at $Global:iDRAC_System"
}


function Get-iDRACChassisUri
{
 $outputobject = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri $Chassis -Verbose -Credential $credentials).content | ConvertFrom-Json
 $Global:iDRAC_Chassis = "$base_api_uri$($outputobject.Members.'@odata.id')"
 Write-Host -ForegroundColor Green "==> Gota manager at $Global:iDRAC_Chassis"
}

function Get-iDRACManagerElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        $iDRAC_Element
    )
(invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$Global:iDRAC_Manager/$iDRAC_Element" -Verbose -Credential $credentials).content | ConvertFrom-Json

}


function Get-iDRACSystemElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        [ValidateSet('Processors','Storage/Controllers')]
        $iDRAC_Element
    )
$system_element = @()
$members = (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$Global:iDRAC_System/$iDRAC_Element" -Credential $credentials).content | ConvertFrom-Json
foreach ($member in $members.members)
    {
    Write-Host -ForegroundColor Green "==> getting SystemElement $member"
    $system_element += (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri$($member.'@odata.id')" -Credential $credentials).content | ConvertFrom-Json
    }
$system_element.PSTypeNames.Insert(0, "$iDRAC_Element")
Write-Output $system_element
}

function Get-iDRACChassisElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        [ValidateSet('Power','Thermal')]
        $iDRAC_Element
    )
$members = @()
$Chassis_element = @()

$members += (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$Global:iDRAC_Chassis/$iDRAC_Element" -Credential $credentials).content | ConvertFrom-Json
if ($members.count -gt 1)
    {
#$members
    foreach ($member in $members)
        {
        Write-Host -ForegroundColor Green "==> getting ChassisElement  $($member.'@odata.id')"
        $Chassis_element += (invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri$($member.'@odata.id')" -Credential $credentials -Verbose).content | ConvertFrom-Json
        }
    }
else
    {
    $Chassis_element = $members[0]
    }
$Chassis_element.PSTypeNames.Insert(0, "$iDRAC_Element")
Write-Output $Chassis_element
}

function Get-iDRACodata
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("@odata.id")]
        $odata
    )

begin
{}
process
{
Write-Host -ForegroundColor Green "==> getting elements for odata Link $odata"
(invoke-WebRequest -ContentType 'application/json;charset=utf-8' -Uri "$base_api_uri$($odata)" -Credential $credentials -Method Get).content | ConvertFrom-Json

}
end
{}

}