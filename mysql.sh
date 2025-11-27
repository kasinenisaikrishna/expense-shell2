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

dnf install mysql-server -y
validate $? "installing mysql server"

systemctl enable mysqld
validate $? "enabled mysql server"

systemctl start mysqld
validate $? "started mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "setting up root password"