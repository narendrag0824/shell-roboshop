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



dnf install python3 gcc python3-devel -y &>>$logfile
validate $? "installing python"

if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logfile
     validate $? "installing python"
else
   echo -e "already added...$y skipiing $n" 
fi       

mkdir /app &>>$logfile
validate $? "create dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$logfile
validate $? "copy code here"

cd /app 
validate $? "current dir"

rm -rf /app/*
validate $? "remove previous data"

unzip /tmp/payment.zip &>>$logfile
validate $? "unzip code is here"

pip3 install -r requirements.txt &>>$logfile
validate $? "dependencyes installing"

cp $script_dir/payment.service /etc/systemd/system/payment.service &>>$logfile
validate $? "copy payment.service here"

systemctl daemon-reload &>>$logfile
validate $? "reloading "

systemctl enable payment &>>$logfile
validate $? "enabling payment"

systemctl start payment &>>$logfile
validate $? "starting payment"