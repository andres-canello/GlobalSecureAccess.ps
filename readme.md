# GlobalSecureAccess.ps

This is a community-supported PowerShell module which simplifies managing Entra Private Access apps. The module calls the Graph API endpoints to perform common operations.
Please contribute and report issues.

Here's some commands to try:

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
