#!/bin/bash

amiid="ami-09c813fb71547fc4f"
sgid="sg-05ceca7471f660a07"
zoneid="Z0442981UILX0S96GDLC"
domainname="narendra.fun"

for instance in $@
do
      instanceid=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-05ceca7471f660a07 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance != "frontend" ]; then
    ip=$(aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    recordname="$instance.$domainname"

else
    ip=$(aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[0].Instances[0].PublicIpAddress" --output text) 
    recordname="$domainname"
fi 
 echo "$instance=$ip"
  aws route53 change-resource-record-sets \
    --hosted-zone-id $zoneid \
    --change-batch '
	{
  "Comment": "Update record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$recordname'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$ip'"
          }
        ]
      }
    }
  ]
}
'
done