Param(
	[Parameter(Position=0, HelpMessage='FQDN of the ConnectionBroker for the RDS deployment')]
	[String] $ConnectionBroker = ([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName),
	[Parameter(Position=1, Mandatory=$True, HelpMessage='External FQDN for the remotedesktop gateway')]
	[String] $GatewayExternalFQDN
)

Configuration RDGConfig
{
	Param(
		[Parameter(Mandatory=$True)]
		[String] $ConnectionBroker,
		[Parameter(Mandatory=$True)]
		[String] $GatewayExternalFQDN
	)

    Import-DSCResource -ModuleName RDSGateway

    RDDeployGatewayConfig RDGatewayConfig
    { 
		ConnectionBroker = $ConnectionBroker
		GatewayExternalFQDN = $GatewayExternalFQDN
		BypassLocal = $false
    }
}

$MOFPath = 'C:\Support\MOF'
If (!(Test-Path $MOFPath)){New-Item -Path $MOFPath -ItemType Directory}
RDGConfig -OutputPath $MOFPath #-ConfigurationData $ConfigData -DomainCred $DomainCred -NodeName $nodename 
Start-DscConfiguration -Path $MOFPath -Computername 'localhost' -Wait -Force -Verbose