function Get-GSAPrivateAccessApp {
	<#
	.SYNOPSIS
	    Gets Private Access apps.
	.DESCRIPTION
		Gets Private Access apps.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessApp
		Gets all the Private Access apps in the tenant.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessApp -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628
		Gets a single Private Access app.
	#>
	[CmdletBinding(DefaultParameterSetName = 'AllPrivateAccessApps')]
	param (

		[Parameter(Mandatory = $True, Position = 1, ParameterSetName = 'SingleAppID')]
		[string]
		$ObjectID,
		
		[Parameter(Mandatory = $False, ParameterSetName = 'SingleAppName')]
		[string]
		$AppName
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}

	$common = @{
		Method = 'GET'
	}



	switch ($PSCmdlet.ParameterSetName) {
		"AllPrivateAccessApps" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications?`$count=true&`$select=displayName,appId,id,tags,createdDateTime,servicePrincipalType,createdDateTime,servicePrincipalNames,&`$filter=tags/Any(x: x eq 'PrivateAccessNonWebApplication') or tags/Any(x: x eq 'NetworkAccessManagedApplication') or tags/Any(x: x eq 'NetworkAccessQuickAccessApplication')"
			break
		}			
		"SingleAppID" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications/$ObjectID/?`$select=displayName,appId,id,tags,createdDateTime,servicePrincipalType,createdDateTime,servicePrincipalNames" -Raw
			break
		}
		"SingleAppName" {
			# To do
			#Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications/$AppObjectID/?`$select=displayName,appId,id,tags,createdDateTime,servicePrincipalType,createdDateTime,servicePrincipalNames" -Raw
			break
		}
	}
	
}
