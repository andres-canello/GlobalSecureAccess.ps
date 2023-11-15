function New-GSAPrivateAccessAppNetworkSegment {
	<#
	.SYNOPSIS
	    Adds a network segment to an existing Private Access app.
	.DESCRIPTION
		Adds a network segment to an existing Private Access app.
	.EXAMPLE
	    PS C:\>Get-AzureADUserAuthenticationMethod -ObjectId user@contoso.com -Phone
		Gets the phone authentication methods set for the user.
	.EXAMPLE
	    PS C:\>Get-AzureADUser -SearchString user1@contoso.com | Get-AzureADUserAuthenticationMethod
		Gets the phone authentication methods set for the user from the pipeline.
	.EXAMPLE
	    PS C:\>Get-AzureADUserAuthenticationMethod -UserPrincipalName user@contoso.com -Phone
		Gets the phone authentication methods set for the user.
	.EXAMPLE
	    PS C:\>Get-AzureADUserAuthenticationMethod user@contoso.com -MicrosoftAuthenticator -ReturnDevices
		Gets the Microsoft Authenticator authentication methods set for the user including the properties of the device object (only for Phone Sign In).
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
