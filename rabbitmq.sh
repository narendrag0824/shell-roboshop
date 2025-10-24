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

cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "copy script from anthor folder"

dnf install rabbitmq-server -y &>>$logfile
validate $? "installing rabbitmq"


systemctl enable rabbitmq-server &>>$logfile
validate $? "enable"


systemctl start rabbitmq-server &>>$logfile
validate $? "start "

if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$logfile
else
    echo -e "user already added...$y skipping $n"     
fi    
validate $? "user adding"


rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$logfile
validate $? "settingup permissions"

