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


dnf install maven -y &>>$logfile
validate $? "installing maven"

if [ $/ -ne 0 ]; then
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
     echo -e "user already added...$y skipping $n" 
fi           
validate $? "user added"

mkdir -p /app &>>$logfile
validate $? "create dir"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$logfile
validate $? "copy the code"

cd /app 
validate $? "open current dir"

unzip /tmp/shipping.zip &>>$logfile
validate $? "unzip the code"

mvn clean package &>>$logfile
mv target/shipping-1.0.jar shipping.jar &>>$logfile
validate $? "dependencyes installing"

cp $script_dir/shipping.service /etc/systemd/system/shipping.service &>>$logfile
validate $? "move shiiping.service to here"

systemctl daemon-reload &>>$logfile
validate $? "deamon reloading"

systemctl enable shipping &>>$logfile
validate $? "enable shipping"

systemctl start shipping &>>$logfile
validate $? "start shipping"
if
dnf install mysql -y &>>$logfile
validate $? "install mysql"

mysql -h $mysqlhost -uroot -pRoboShop@1 -e 'use cities' &>>$logfile
if [ $? -ne 0 ]; then
      mysql -h $mysqlhost -uroot -pRoboShop@1 < /app/db/schema.sql
      mysql -h $mysqlhost -uroot -pRoboShop@1 < /app/db/app-user.sql 
      mysql -h $mysqlhost -uroot -pRoboShop@1 < /app/db/master-data.sql
else
   echo -e "shipping data already loaded...$y skipping $n"   
fi      

systemctl restart shipping &>>$logfile
validate $? "reastarting"