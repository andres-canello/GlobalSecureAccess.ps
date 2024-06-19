$csvFile = "C:\temp\AppSegments.csv"
 
# Assuming the CSV file has columns named 'AppOId', 'iprange', 'ports', 'protocol', 'type'
$variables = Import-Csv $csvFile
 
# Loop through each row of the CSV and execute the command for each set of variables
foreach ($variable in $variables) {
    $AppOId = $variable.AppOId
    $iprange = $variable.iprange
    $ports = $variable.ports -split ","
    $protocol = $variable.protocol -split ","
    $type = $variable.type
 

    # Execute the command
    Get-GSAPrivateAccessApp $AppOId | New-GSAPrivateAccessAppNetworkSegment -DestinationHost $iprange -Ports $ports -Protocol $protocol -DestinationType $type -debug
}