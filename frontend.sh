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


dnf module disable nginx -y &>>$logfile
validate $? "disable nginx"

dnf module enable nginx:1.24 -y &>>$logfile
validate $? "enable nginx"

dnf install nginx -y &>>$logfile
validate $? "install nginx"

systemctl enable nginx &>>$logfile
validate $? "enable nginx"

systemctl start nginx &>>$logfile
validate $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "remove old content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$logfile
validate $? "copy the code here"

cd /usr/share/nginx/html  &>>$logfile
validate $? "change dir"

unzip /tmp/frontend.zip &>>$logfile
validate $? "unzip code here"

rm -rf /etc/nginx/nginx.conf
cp $script_dir/nginx.conf /etc/nginx/nginx.conf &>>$logfile
validate $? "copy nginx.conf is here"

systemctl restart nginx &>>$logfile
validate $? "restart nginx"
