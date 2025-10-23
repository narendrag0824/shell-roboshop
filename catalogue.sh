#!/bin/bash

userid=$(id -u)

r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

logfolder="/var/log/shell-roboshop"
scriptname=$( echo $0 | cut -d "." -f1 )
logfile="$logfolder/$scriptname.log"
mongodbhost="$mangodb.narendra.fun"
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

dnf module disable nodejs -y &>>$logfile
validate $? "disable node js"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enable node js 20"

dnf install nodejs -y &>>$logfile
validate $? "install node js"

id roboshop &>>$logfile
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logfile
    validate $? "createing system user"
else
    echo -e "user alredy exist...$y skiping $n"
fi

mkdir -p /app 
validate $? "create directoty"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$logfile
validate $? "downloading catalogue application"

cd /app
validate $? "changeing to app directory"

rm -rf /app/*
validate $? "remove previous data"

unzip /tmp/catalogue.zip &>>$logfile
validate $? "unzip the code"

npm install &>>$logfile
validate $? "install dependencies"

cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service 
validate $? "copy systm service to catalogue user"

systemctl daemon-reload
validate $? "deamon reload"

systemctl enable catalogue 
validate $? "enable catalogue"

systemctl start catalogue
validate $? "start catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongo.repo"

dnf install mongodb-mongosh -y &>>$logfile
validate $? "install mongodb"

mongosh --host $mongodbhost </app/db/master-data.js
validate $? "load catalogue products"

systemctl restart catalogue
validate $? "restart"
