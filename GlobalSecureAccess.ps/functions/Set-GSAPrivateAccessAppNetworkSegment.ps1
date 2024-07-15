function Set-GSAPrivateAccessAppNetworkSegment {
	<#
	.SYNOPSIS
	    Adds a network segment to an existing Private Access app.
	.DESCRIPTION
		Adds a network segment to an existing Private Access app.
	.EXAMPLE
	    PS C:\>New-GSAPrivateAccessAppNetworkSegment -DestinationHost ssh.contoso.com -Ports 22 -Protocol tcp -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628
		Adds a network segment to an existing Private Access app.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessApp 6e8e602b-466e-446c-99fa-ac4151748628 | New-GSAPrivateAccessAppNetworkSegment -DestinationHost ssh.contoso.com -Ports 22 -Protocol tcp
		Adds a network segment to an existing Private Access app, getting the app id from the pipeline.
	#>
	[CmdletBinding()]
	param (

		[Alias('id')]
		[Parameter(Mandatory = $True, Position = 1)]
		[string]
		$ObjectID,

		[Parameter(Mandatory = $True, Position = 2)]
		[string]
		$NetworkSegmentID,
		
		[Parameter(Mandatory = $False)]
		[string]
		$DestinationHost,
		
		[Parameter(Mandatory = $False)]
		[string[]]
		$Ports,
		
		[Parameter(Mandatory = $False)]
		[ValidateSet("TCP", "UDP")]
		[string[]]
		$Protocol,

		[Parameter(Mandatory = $False)]
		[ValidateSet("ipAddress", "dnsSuffix", "ipRangeCidr","ipRange","FQDN")]
		[string]
		$DestinationType
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}


	$portRanges = @()

	foreach ($port in $Ports){
		if (!$port.Contains("-")) {
			$portRanges += $port + "-" + $port
		}
		else {
			$portRanges += $port
		}

	}

	if ($DestinationType -eq "dnsSuffix")
	{
		$body = @{
			destinationHost = $DestinationHost.ToLower()
			destinationType = 'dnsSuffix'
			}
	}
	else
	{
			switch ($DestinationType) {
				"ipAddress" { $dstType = 'ipAddress' }
				"ipRange" { $dstType = 'ipRange' }
				"fqdn" { $dstType = 'fqdn' }
				"ipRangeCidr" { $dstType = 'ipRangeCidr' }
			}

		$body = @{}
		if ($DestinationType) {$body.destinationType = $dstType}
		if ($DestinationHost) {$body.destinationHost = $DestinationHost.ToLower()}
		if ($Protocol) {$body.protocol = $Protocol.ToLower()}
		if ($Ports) {$body.ports = $portRanges}
		
	}

	$bodyJson = $body | ConvertTo-Json -Depth 99 -Compress

	$params = @{
		Method = 'PATCH'
		Query = "https://graph.microsoft.com/beta/applications/$ObjectID/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/$NetworkSegmentID"
		Body = $bodyJson

	}

	Invoke-GSARequest @params -Raw
	
}
