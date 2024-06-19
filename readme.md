# GlobalSecureAccess.ps

This is a community-supported PowerShell module which simplifies managing Entra Private Access apps. The module calls the Graph API endpoints to perform common operations.
Please contribute and report issues.

Here are some commands to try:

### Download the module and import it

Import-Module "C:\Git\GlobalSecureAccess.ps\GlobalSecureAccess.ps\GlobalSecureAccess.ps.psm1"

### Connect the GlobalSecureAccess.ps module to the Entra tenant.

Connect-GSATenant

### Get all the Private Access apps or a single one (use the App object id, no Service Principals)

Get-GSAPrivateAccessApp

Get-GSAPrivateAccessApp -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628

### Get all the network segments for an app, or a specific app segment

Get-GSAPrivateAccessAppNetworkSegment -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628

Get-GSAPrivateAccessAppNetworkSegment 6e8e602b-466e-446c-99fa-ac4151748628 -NetworkSegmentID 05b319f5-1e5b-48f3-95b4-f78cf010fdbf

### Get the app and pipe the result to get all the app segments

Get-GSAPrivateAccessApp 6e8e602b-466e-446c-99fa-ac4151748628 | Get-GSAPrivateAccessAppNetworkSegment

### Get an app and create a new app segment

Get-GSAPrivateAccessApp 6e8e602b-466e-446c-99fa-ac4151748628 | New-GSAPrivateAccessAppNetworkSegment -DestinationHost ssh.contoso.net -Ports 22 -Protocol tcp

### Add an IP range app segment
Get-GSAPrivateAccessApp 58c59e74-5b92-4578-bef5-36b86ac97f0a | New-GSAPrivateAccessAppNetworkSegment -Ports 10000-16000 -Protocol tcp,udp -DestinationHost 192.168.1.100..192.168.1.101 -DestinationType ipRange

### Remove an app segment

Remove-GSAPrivateAccessAppNetworkSegment -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628 -NetworkSegmentID 6e8e602b-466e-446c-99fa-ac4151748611

### Get a connector
Get-GSAConnector -ConnectorID '00000000-0000-0000-0000-000000000000'

### Get all connectors in a connector group
Get-GSAConnector -ConnectorGroupID '00000000-0000-0000-0000-000000000000'

### Get all connector groups
Get-GSAConnectorGroup

### To assign users/groups to apps, you can use the following Graph command:
https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/assign-user-or-group-access-portal?pivots=ms-powershell#assign-users-and-groups-to-an-application-using-microsoft-graph-powershell

Example:
...
# Assign the values to the variables

$userId = "<Your user's ID>"
$app_name = "<Your App's display name>"
$app_role_name = "<App role display name>"
$sp = Get-MgServicePrincipal -Filter "displayName eq '$app_name'"

# Get the user to assign, and the service principal for the app to assign to

$params = @{
    "PrincipalId" =$userId
    "ResourceId" =$sp.Id
    "AppRoleId" =($sp.AppRoles | Where-Object { $_.DisplayName -eq $app_role_name }).Id
    }

# Assign the user to the app role

New-MgUserAppRoleAssignment -UserId $userId -BodyParameter $params |
    Format-List Id, AppRoleId, CreationTime, PrincipalDisplayName,
    PrincipalId, PrincipalType, ResourceDisplayName, ResourceId
...