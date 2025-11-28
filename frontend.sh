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

dnf install nginx -y &>>$log_file
validate $? "installing nginx"

systemctl enable nginx &>>$log_file
validate $? "enable nginx"

systemctl start nginx &>>$log_file
validate $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
validate $? "removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file
validate $? "downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$log_file
validate $? "extract frontend code"

cp /home/ec2-user/expense-shell2/expense.conf /etc/nginx/default.d/expense.conf
validate $? "copied expense conf"

systemctl restart nginx &>>$log_file
validate $? "restarting nginx"