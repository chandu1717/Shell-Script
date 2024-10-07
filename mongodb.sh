#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$($0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo -e  "$R ERROR: YOu are not root user $N"
    exit 1
else
    echo -e "$G INFO: You are root user $N"
fi

VALIDATE(){
    if [ $! -ne 0 ]
    then 
        echo -e "$2 ........$R Failure $N"
        exit 1
    else
        echo -e "$2 ........$G Success $N "
    fi
}

cp /etc/centos/Shell-Script/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copy mongo.repo "

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Install MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "MongoDB Enabled"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "MongoDB Started"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>LOGFILE 
VALIDATE $? "COnfiguration edited "

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "MOngoDB restart "