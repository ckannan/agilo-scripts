#!/bin/sh

if [ $# -lt 7 ];
then
	echo "USAGE: create-task.sh <agilo-url> <agilo-id> <agilo-password>"
	echo "       <task-summary> <task-reporter> <task-description>"
	echo "       <task-remaining-time>"
	exit 1
fi

agilo=$1
user=$2
pass=$3
task_summary=$4
task_reporter=$5
task_description=$6
task_remaining_time=$7


cookies=cookies.txt

# get form token
#echo "Obtaining form token"
curl -s --digest -u "$user:$pass" -c "$cookies" $agilo > /dev/null
formtoken=$( cat cookies.txt | grep trac_form_token | cut -f 7 | tr -d "\r" )

# login; try to log in either form based or with HTTP authentication
# make it in a single run; instead just doing both ways works - either one will work
#echo "Logging into $agilo"
# try logging login for form based login
loginData="__FORM_TOKEN=$formtoken&user=$user&password=$pass"
curl -s -b "$cookies" -c "$cookies" -d "$loginData" $agilo/login > /dev/null
# try logging with digest HTTP authentication
curl -s -b "$cookies" -c "$cookies" --digest -u "$user:$pass"  $agilo/login  > /dev/null

# create task

DATA="field_summary=${task_summary}&field_reporter=${task_reporter}&field_description=${task_description}&field_remaining_time=${task_remaining_time}&field_status=new&submit=Create%2BTicket&field_type=task&__FORM_TOKEN=${formtoken}"
ticket_url=`curl -s -d "${DATA}" -i -b "$cookies" $agilo/newticket  | grep Location | grep -i ticket | awk '{print $2}'`
if [ -n $ticket_url ];
then
	echo "Task created = $ticket_url"
else
	echo "ERROR: problem creating ticket"
fi

rm "$cookies"


