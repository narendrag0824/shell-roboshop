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
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
        echo "user already added...$y SKIPPING $n"
fi           
 validate $? "adding user"

mkdir -p/app 
validate $? "create directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$logfile
validate $? "paste the code"

cd /app 
validate $? "go to dir"

rm -rf /app/*
validate $? "remove previous data"

unzip /tmp/cart.zip &>>$logfile
validate $? "unzip the code"

npm install &>>$logfile 
validate $? "dependencies installing"

cp $script_dir/cart.service /etc/systemd/system/cart.service &>>$logfile
validate $? "copy cart.service to cart "

systemctl daemon-reload &>>$logfile
validate $? "reloading"

systemctl enable cart &>>$logfile
validate $? "enable cart"

systemctl start cart &>>$logfile
validate $? "start cart"
