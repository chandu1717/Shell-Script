#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log
HOST_NAME=mongodb.devrob.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo -e "$R Error: You are not root user $N "
    exit 1
else
    echo -e "$G Info: You are root user $N "
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then   
        echo -e "$R.....Failure $N"
        exit 1
    else
        echo -r "$G.....Success $N"
    fi    
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "node js module disabled"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "node  js module enabled"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "node  js installed"

id roboshop &>> $LOGFILE
if [ $useradd -ne roboshop ]
then 
    echo -e "$G User doesn't exists creating new user $N"
    useradd roboshop &>> $LOGFILE
else
    echo -e "$R User Already exists $N......$Y SKIPPING $N"
fi

rm -rf /app &>> $LOGFILE

mkdir -p /app &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE  $? "catalogue zip downloaded"

cd /app  &>> $LOGFILE
VALIDATE  $? "cd to app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE  $? "catalogue unzipped"

cd /app &>> $LOGFILE

npm install &>>  $LOGFILE
VALIDATE $? "npm install"

cp /etc/centos/Shell-Script/catalogue.service /etc/systemd/system/catalogue.service &>>  $LOGFILE
VALIDATE $? "catalogue service copied"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE  $? "systemd daemon reloaded"

systemctl  enable catalogue &>> $LOGFILE
VALIDATE $? "catalogue service enabled"

systemctl start catalogue &>> $LOGFILE
VALIDATE  $? "catalogue service started"

cp /etc/centos/Shell-Script/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $?  "mongo repo copied"

mongo --host $HOST_NAME </app/schema/catalogue.js &>>  $LOGFILE

