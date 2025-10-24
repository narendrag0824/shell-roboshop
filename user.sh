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
validate $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enable nodejs"

dnf install nodejs -y &>>$logfile
validate $? "install nodejs"

if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logfile
     validate $? "useradd"
else
     echo -e "user already added...$y skiping $n"  
fi        

mkdir -p /app 
validate $? "create dir"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$logfile
validate $? "paste the code"

cd /app 
validate $? "move to current dr"

rm -rf /app/*
validate $? "remove previous data"

unzip /tmp/user.zip &>>$logfile
validate $? "unzip the code"

npm install &>>$logfile
validate $? "dependencys install"

cp $script_dir/user.service /etc/systemd/system/user.service &>>$logfile
validate $? "copy cart.service to cart"

systemctl daemon-reload
validate $? "reloading"

systemctl enable user &>>$logfile
validate $? "enable"

systemctl start user &>>$logfile
validate $? "start"