#!/bin/bash

logs_folder="/var/log/expense"
script_name=$(echo $0 | cut -d "." -f1)
time_stamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$logs_folder/$script_name-$time_stamp.log"
mkdir -p $logs_folder

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
    if [ $userid -ne 0 ]
    then
        echo -e "$R Please run this script with root access $N" | tee -a $log_file
        exit 1
    fi
}

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is...$G success $N" | tee -a $log_file
    fi
}

echo "script started executing at: $(date)" | tee -a $log_file

check_root

dnf module disable nodejs -y &>>$log_file
validate $? "disable default nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enable nodejs:20"

dnf install nodejs -y &>>$log_file
validate $? "install nodejs"

id expense &>>$log_file
if [ $? -ne 0 ]
then
    echo -e "expense user is not there $G creating $N now"
    useradd expense &>>$log_file
    validate $? "creating expense user"
else
    echo -e "expense user is already present $Y skipping $N"
fi

mkdir -p /app
validate $? "creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_file
validate $? "downloading backend application code"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>$log_file
validate $? "extracting backend application code"