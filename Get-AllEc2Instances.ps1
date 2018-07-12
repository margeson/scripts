import-module AWSPowerShell

echo InstanceID,Name,State >> Get-AllEc2Instances.csv
#Get regions
$regions = Get-AWSRegion | select -ExpandProperty region
foreach($region in $regions){

    #Get instance ids
    $instanceIds = (Get-EC2Instance -Region $region).Instances | select -ExpandProperty instanceid

    #For each instance id
    foreach($instanceId in $instanceIds){

        #Get instance tag
        $tag = (Get-EC2Instance -Region $region).Instances | ?{$_.InstanceId -eq $instanceId} | select -ExpandProperty tag | ?{$_.Key -eq "Name"} | select -ExpandProperty value        
        #Get private ips
        $state = (Get-EC2Instance -Region $region).Instances | ?{$_.InstanceId -eq $instanceId} | select -ExpandProperty state | select -ExpandProperty Name
        #Print info
        "$region,$instanceId,$tag,$state" >> Get-AllEc2Instances.csv
    }
}
