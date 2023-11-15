function New-GSAPrivateAccessAppNetworkSegment {
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
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$ObjectID,
		
		[Parameter(Mandatory = $True)]
		[string]
		$DestinationHost,
		
		[Parameter(Mandatory = $True)]
		[string[]]
		$Ports,
		
		[Parameter(Mandatory = $True)]
		[ValidateSet("TCP", "UDP")]
		[string]
		$Protocol

		
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

	$body = @{
		destinationHost = $DestinationHost.ToLower()
		protocol = $Protocol.ToLower()
		ports = $portRanges
	}

	$bodyJson = $body | ConvertTo-Json -Depth 99 -Compress

	$params = @{
		Method = 'POST'
		Query = "https://graph.microsoft.com/beta/applications/$ObjectID/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/"
		Body = $bodyJson

	}

	Invoke-GSARequest @params -Raw
	
}
