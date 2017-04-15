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

function New-iDRACSession
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
                   ValueFromPipeline=$true)][pscredential]$Credentials,
        [switch]$trustCert
    )
    Begin
    {
    if ($trustCert.IsPresent)
        {
        Unblock-Certs
        }
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    }
    Process
    {
    if (!$Credentials)
        {
        $User = Read-Host -Prompt "Please Enter iDRAC username"
        $SecurePassword = Read-Host -Prompt "Enter iDRAC Password for user $user" -AsSecureString
        $Credentials = New-Object System.Management.Automation.PSCredential ($user,$Securepassword)
        }
    write-Verbose "Generating Login Token"
    $Global:iDRAC_baseurl = "https://$($iDRAC_IP):$iDRAC_Port" # :$iDRAC_Port"
    $Global:iDRAC_Credentials = $Credentials
    Write-Verbose $iDRAC_baseurl
    try
        {
		$Body = @{'UserName'= $($Credentials.UserName);'Password'= $($Credentials.GetNetworkCredential().Password)} |ConvertTo-Json -Compress
		Write-Verbose $Body
		$token = Invoke-WebRequest -Uri "$Global:iDRAC_baseurl/redfish/v1/Sessions" -Method Post -Body $Body -ContentType 'application/json' -UseBasicParsing
       
		 }
    catch
        {
        # Write-Warning $_.Exception.Message
        Get-iDRACWebException -ExceptionMessage $_
        Break
        }
        #>
		$Global:iDRAC_XAUTH = $token.Headers.'X-Auth-Token'
		$Global:iDRAC_Session_ID = ($token.Content | ConvertFrom-Json).id
		$Global:iDRAC_Session_URI = $token.Headers.Location
		$host.ui.RawUI.WindowTitle = "iDRAC IP: $iDRAC_IP, Session $Global:iDRAC_Session_ID for user $($Credentials.username)"
        Write-Host "Successfully connected to iDRAC with IP $iDRAC_IP and Session ID $iDRAC_Session_ID"
        Write-Host " we got the following Schemas: "
		$Global:iDRAC_Headers = @{'X-Auth-Token'= $iDRAC_XAUTH} # | ConvertTo-Json -Compress
        $Global:iDRAC_Schemas = (Invoke-WebRequest -UseBasicParsing "$Global:iDRAC_baseurl/redfish/v1/odata" -Headers $Global:iDRAC_Headers -ContentType 'Application/Json' ).content | ConvertFrom-Json | select -ExpandProperty value

		$Global:iDRAC_Schemas 
		#$Schemas
		Get-iDRACManagerUri
		Get-iDRACChassisUri
		Get-iDRACSystemUri

    }
    End
    {
    }
}
function Invoke-iDRACRequest
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true)]$uri,
		[Parameter(Mandatory=$false)][ValidateSet('Get','Delete','Put','Post','Patch')]$Method = 'Get',
		[Parameter(Mandatory=$false)]$ContentType = 'application/json;charset=utf-8', 
		[Parameter(Mandatory=$false)]$Body

	)

if ($Global:iDRAC_Headers)
	{
	try
		{
		Write-verbose "==> Calling $uri with Session $Global:iDRAC_Session_ID"
		if ($Body)
			{
			$Result = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method $Method -Headers $Global:iDRAC_Headers -ContentType $ContentType -Body $Body
			}
		else
			{
			$Result = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method $Method -Headers $Global:iDRAC_Headers -ContentType $ContentType
			}
		}
	catch
        {
        # Write-Warning $_.Exception.Message
        Get-iDRACWebException -ExceptionMessage $_
        Break
        }
	}
else
	{
	Write-Host -ForegroundColor White "==> Calling $uri with Basic Auth for User $($Global:iDRAC_Credentials.Username)"
	if ($Body)
		{
		$Result = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method $Method -Credential $Global:iDRAC_Credentials -ContentType $ContentType -Body $Body
		}
	else
		{
		$Result = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method $Method -Credential $Global:iDRAC_Credentials -ContentType $ContentType
		}
	}
Write-Output $Result
}
function Disconnect-iDRACSession
{
    [CmdletBinding(DefaultParameterSetName='ByUri')]
    [OutputType([int])]
	Param
    (
    [Parameter(Mandatory=$false,ParameterSetName = "ByUri")]$Session_Uri = $Global:iDRAC_Session_URI,
    [Parameter(Mandatory=$false,ParameterSetName = "ByID")]$Session_ID

	#[Parameter(Mandatory=$false)]$Idrac_Uri = $Global:iDRAC_baseurl
	)

if ($Session_ID)
	{
	$Session_Uri = "/redfish/v1/Sessions/$Session_ID"
	}
Write-Host -ForegroundColor Green "==> Calling delete $Session_Uri with Session $Global:iDRAC_Session_ID"
$Disconnect = Invoke-iDRACRequest -Uri $Global:iDRAC_baseurl$Session_Uri -Method Delete
Write-Host ($Disconnect.Content | ConvertFrom-Json).'@Message.ExtendedInfo'.Message
}

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
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    }
    Process
    {
    if (!$Credentials)
        {
        $User = Read-Host -Prompt "Please Enter iDRAC username"
        $SecurePassword = Read-Host -Prompt "Enter iDRAC Password for user $user" -AsSecureString
        $Credentials = New-Object System.Management.Automation.PSCredential ($user,$Securepassword)
        }
    write-Verbose "Generating Login Token"
    $Global:iDRAC_baseurl = "https://$($iDRAC_IP):$iDRAC_Port" # :$iDRAC_Port"
    $Global:iDRAC_Credentials = $Credentials
    Write-Verbose $iDRAC_baseurl
    try
        {
        $Schemas = (Invoke-WebRequest -UseBasicParsing "$Global:iDRAC_baseurl/redfish/v1/odata" -Credential $credentials -ContentType 'Application/Json' ).content | ConvertFrom-Json | select -ExpandProperty value
        }
    catch
        {
        Get-iDRACWebException -ExceptionMessage $_
        Break
        }
        Write-Host "Successfully connected to iDRAC with IP $iDRAC_IP"
        Write-Host " we got the following Schemas: "
        $Global:iDRAC_Schemas = $Schemas
		#$Schemas
		Get-iDRACManagerUri
		Get-iDRACChassisUri
		Get-iDRACSystemUri

    }
    End
    {
    }
}
function Get-iDRACManagerUri
{

$Myself = $MyInvocation.MyCommand.Name.Substring(9) -replace "URI" 
$Schema = ($Global:iDRAC_schemas | where name -Match $Myself).URL
$outputobject = (Invoke-iDRACRequest  -Uri "$Global:iDRAC_baseurl$Schema").content | ConvertFrom-Json
$Global:iDRAC_Manager = "$base_api_uri$($outputobject.Members.'@odata.id')"
$Global:iDRAC_OEM = (Get-iDRACodata -odata $iDRAC_Manager).Actions.Oem
Write-Host -ForegroundColor Green "==< Got $Myself URI $Global:iDRAC_Manager"
} 
function Get-iDRACSystemUri
{
$Myself = $MyInvocation.MyCommand.Name.Substring(9) -replace "URI" 
$Schema = ($Global:iDRAC_schemas | where name -Match $Myself).URL
$outputobject = (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Schema" ).content | ConvertFrom-Json
$Global:iDRAC_System = "$base_api_uri$($outputobject.Members.'@odata.id')"
Write-Host -ForegroundColor Green "==< Got $Myself URI $Global:iDRAC_System"
}
function Get-iDRACChassisUri
{
$Myself = $MyInvocation.MyCommand.Name.Substring(9) -replace "URI" 
$Schema = ($Global:iDRAC_schemas | where name -Match $Myself).URL
$outputobject = (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Schema").content | ConvertFrom-Json
$Global:iDRAC_Chassis = "$base_api_uri$($outputobject.Members.'@odata.id')" 
$Global:iDRAC_Chassis = $Global:iDRAC_Chassis -split " "
Write-Host -ForegroundColor Green "==< Got $Myself URI $Global:iDRAC_Chassis"
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
(Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Global:iDRAC_Manager/$iDRAC_Element" ).content | ConvertFrom-Json

}


function Get-iDRACSystemElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        [ValidateSet('Processors','Storage/Controllers','EthernetInterfaces')]
        $iDRAC_Element
    )
$system_element = @()
$members = (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Global:iDRAC_System/$iDRAC_Element").content | ConvertFrom-Json
if ($members.members.count -gt 1)
    {
	foreach ($member in $members.members)
		{
		Write-Host -ForegroundColor Green "==> getting SystemElement $member"
		$system_element += (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$($member.'@odata.id')").content | ConvertFrom-Json
		}
    }
else
    {
    $system_element = $members[0]
    }

if (!$iDRAC_Element)
	{
	$system_element.PSTypeNames.Insert(0, "System")
	}
else
	{
	$system_element.PSTypeNames.Insert(0, "$iDRAC_Element")
	}
Write-Output $system_element
}
function Get-iDRACChassisElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        [ValidateSet('Power','Thermal')]
        $iDRAC_Element
    )
$members = @()
$Chassis_element = @()
foreach ($chassis in $Global:iDRAC_Chassis)
	{
	Write-Verbose $chassis
	$members = (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$chassis/$iDRAC_Element").content | ConvertFrom-Json

	if ($members.count -gt 1)
		{
	#$members
		foreach ($member in $members.member)
			{
			Write-Host -ForegroundColor Green "==> getting ChassisElement  $($member.'@odata.id')"
			$Chassis_element += (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$($member.'@odata.id')").content | ConvertFrom-Json
			}
		}
	else
		{
		$Chassis_element = $members[0]
		}
	if ($iDRAC_Element) 
		{
		$Chassis_element.PSTypeNames.Insert(0, "$iDRAC_Element")
		}
	else
		{
		$Chassis_element.PSTypeNames.Insert(0, "Chassis")
		}
Write-Output $Chassis_element
	}
}
function Get-iDRACManagerElement
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        [Alias("Function")]
        [ValidateSet('LogServices','NetworkProtocol')]
        $iDRAC_Element
    )
$members = @()
$Manager_element = @()

$members += (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Global:iDRAC_Manager/$iDRAC_Element").content | ConvertFrom-Json
if ($members.members.count -gt 1)
    {
#$members
    foreach ($member in $members.members)
        {
        Write-Host -ForegroundColor Green "==> getting ManagerElement  $($member.'@odata.id')"
        $Manager_element += (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$($member.'@odata.id')").content | ConvertFrom-Json
        }
    }
else
    {
    $Manager_element = $members[0]
    }
if ($iDRAC_Element) 
	{
	$Manager_element.PSTypeNames.Insert(0, "$iDRAC_Element")
	}
else
	{
	$Manager_element.PSTypeNames.Insert(0, "Manager")
	}
Write-Output $Manager_element
}


function Get-iDRACLifecycleLog
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        #[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
        #[Alias("Function")]
        #[ValidateSet('LogServices','NetworkProtocol')]
        #$iDRAC_Element
    )
$members = @()
$Manager_element = @()

$members = (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$Global:iDRAC_Manager/Logs/Lclog").content | ConvertFrom-Json
<#
if ($members.members.count -gt 1)
    {
        Write-Host -ForegroundColor Green "==> getting ManagerElement  $($member.'@odata.id')"
        $Manager_element = $Members.Content | ConvertFrom-Json | select -ExpandProperty Members
		# += (Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$($member.'@odata.id')").content | ConvertFrom-Json

    }
else
    {
    $Manager_element = $members[0]
    }

	$Manager_element.PSTypeNames.Insert(0, "LifecycleLogs")


# $members.PSTypeNames.Insert(0, "LifecycleLogs")#>
Write-Output $members.members
}
function Get-iDRACodata
{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1',Position = 0)]
        [Alias("@odata.id")]
        $odata
    )

begin
{}
process
{
Write-Verbose "==> getting elements for odata Link $odata"
(Invoke-iDRACRequest -Uri "$Global:iDRAC_baseurl$($odata)").content | ConvertFrom-Json

}
end
{}

}



function Get-iDRACSessions
{

$Sessions = @()
$iDRAC_Sessions = @()
$Sessions = ((Invoke-iDRACRequest -uri $iDRAC_baseurl/redfish/v1/Sessions).Content | ConvertFrom-Json).members

foreach ($session in $Sessions)
	{
	$iDRAC_Sessions += (Invoke-iDRACRequest -uri $iDRAC_baseurl$($session.'@odata.id')).content | ConvertFrom-Json
	}
$iDRAC_Sessions.PSTypeNames.Insert(0, "iDRACSessions")
Write-Output $iDRAC_Sessions
}


function Copy-iDRACSCP
{

param( 
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]$Cifs_IP = "172.21.1.103",
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)][pscredential]$Credentials,
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]$Cifs_Sharename = "dscfra",
#$ShareType = "CIFS"
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]$Filename = "SCP_XML.xml",
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]
		   [ValidateSet("ALL", "IDRAC", "BIOS", "NIC", "RAID")]$Target = "ALL",   
		   <#"ALL", "IDRAC", "BIOS", "NIC", "RAID"#>
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)][switch]$waitcomplete
)
$Target_Uri = $Global:iDRAC_OEM.'OemManager.v1_0_0#OemManager.ExportSystemConfiguration'.Target
if (!$Credentials)
        {
        $User = Read-Host -Prompt "Please Enter CIFS username for $Cifs_IP"
        $SecurePassword = Read-Host -Prompt "Enter CIFS Password for user $user" -AsSecureString
        $Credentials = New-Object System.Management.Automation.PSCredential ($user,$Securepassword)
        }


$JsonBody = @{ ExportFormat ="XML"
   ShareParameters = @{
    Target=$Target
    IPAddress=$Cifs_IP
    ShareName=$Cifs_Sharename
    ShareType="CIFS"
    UserName=$Credentials.UserName
    Password=$Credentials.GetNetworkCredential().Password
    FileName=$Filename}} | ConvertTo-Json
#$JsonBody
$result = Invoke-iDRACRequest -uri "$iDRAC_baseurl$Target_Uri" -Method Post -Body $JsonBody -ContentType 'Application/json'

#
if ($waitcomplete.IsPresent)
	{
	Write-Host -ForegroundColor Yellow -NoNewline "Waiting for Task $($result.Headers.location)"
	do {sleep 5} until ((Get-iDRACodata -odata $($result.Headers.location)).TaskState -eq 'Completed')
	Write-Host -ForegroundColor Green "[Task Completed]"
	}
else
	{
	Write-Host "You can Monitor the Task by 'Get-iDRACodata $($result.Headers.location)'"
	}
Get-iDRACodata -odata $result.Headers.location

}
