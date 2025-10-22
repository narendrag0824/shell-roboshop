#!/bin/bash

AMI-ID="ami-09c813fb71547fc4f"
SG-ID="sg-05ceca7471f660a07"

for instance in $@
do
      instanceid=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-05ceca7471f660a07 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance _ne "frontend" ]; then
    ip=$(aws ec2 describe-instances --instance-ids i-00914683ababcba7eb1 --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

else
    ip=$(aws ec2 describe-instances --instance-ids i-00914683ababcba7eb1 --query "Reservations[0].Instances[0].PublicIpAddress" --output text) 
fi 
 echo "$instance=$ip"

done