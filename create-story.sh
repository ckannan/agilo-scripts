#!/bin/sh

if [ $# -lt 6 ];
then
	echo "USAGE: create-story.sh <agilo-url> <agilo-id> <agilo-password>"
	echo "       <summary> <reporter> <description>"
	exit 1
fi

agilo=$1
user=$2
pass=$3
summary=$4
reporter=$5
description=$6


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

# create story

DATA="field_type=User+Story&field_summary=${summary}&field_reporter=${reporter}&field_description=${description}&field_keywords=${keywords}&field_rd_points=${rdpoints}&field_sprint=${sprint}&field_story_priority=${priority}&field_req_priority=1&field_owner=&field_status=new&submit=Create+ticket&__FORM_TOKEN=${formtoken}"

ticket_url=`curl -s -d "${DATA}" -i -b "$cookies" $agilo/newticket  | grep Location | grep -i ticket | awk '{print $2}'`
if [ -n $ticket_url ];
then    
        echo "Story created = $ticket_url"
else
        echo "ERROR: problem creating story"
fi


rm "$cookies"


