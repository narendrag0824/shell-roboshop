#!/bin/bash

userid=$(id -u)

r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

logfolder="/var/log/shell-roboshop"
scriptname=$( echo $0 | cut -d "." -f1 )
logfile="$logfolder/$scriptname.log"
mongodbhost="mongodb.narendra.fun"
mysqlhost="mysql.narendra.fun"
script_dir="$(pwd)"

mkdir -p $logfolder
echo "script started excuted: $(date)"

if [ $userid -ne 0 ]; then
    echo -e "error::please run as sudo user"
    exit 1
fi

validate(){
  if [ $1 -ne 0 ]; then
      echo -e "$2 ... $r is failed $n"
      exit 1
  else
      echo -e "$2 ... $g is success $n"
  fi      
}

dnf install python3 gcc python3-devel -y


useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop


mkdir /app 


curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 


cd /app 


unzip /tmp/payment.zip


pip3 install -r requirements.txt


/etc/systemd/system/payment.service


systemctl daemon-reload


systemctl enable payment 


systemctl start payment
