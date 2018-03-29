#!/bin/bash
app_name=$1
comp_name=$2

if [ ! -z $3 ]; then
    echo "Initiaing UCD Deployment for ${UCD_DA}:${UC} on ${UCD_DE} Environments";

	for env_name in $(echo $3 | tr "," "\n")
	do
		echo "{
		  "application": "$app_name",
		  "description": "Requesting deployment for $app_name",
		  "applicationProcess": "${UCD_Process}",
		  "environment": "$env_name",
		  "onlyChanged": "false",
		  "versions": [
						{
						  "version": "latest",
						  "component": "$comp_name"
						}
		  ]
		}" > $app_name-$env_name.json
		chmod 777 $app_name-$env_name.json
		UCD_REQUEST_ID=`/apps/build/udclient/udclient -weburl https://ucd.kp.org:8443 -username rational.jazz.builduser.Tapestry -authtoken 5a145b18-f1d1-4ed4-b7ba-f92016efc842 requestApplicationProcess $app_name-$env_name.json`
		echo "Deploying $app_name in $env_name"
		UCD_REQUEST_ID=`echo $UCD_REQUEST_ID | cut -c 16-51`
		echo "UCD_REQUEST_ID: $UCD_REQUEST_ID"
		sleep 300;

		flag=1
		echo $UCD_REQUEST_ID
		while test $flag -gt 0
		do
			sleep 60;
			RESULT=`/apps/build/udclient/udclient -weburl https://ucd.kp.org:8443 -username rational.jazz.builduser.Tapestry -authtoken 5a145b18-f1d1-4ed4-b7ba-f92016efc842 getApplicationProcessRequestStatus -request $UCD_REQUEST_ID`
			echo "Current Status: $RESULT"
			echo $RESULT | grep -q '"status": "FAULTED"'
			flag=`echo $?`
			if [ $flag -eq 0 ]
			then
				echo "Deployment Failed. Refer this link for full deployment details: https://ucd.kp.org:8443/#applicationProcessRequest/$UCD_REQUEST_ID"
				echo $RESULT
				break
			else
				echo $RESULT | grep -q '"result": "SUCCEEDED"'
				flag=`echo $?`
				if [ $flag -eq 0 ]
				then
					echo "Deployment Succeeded. Refer this link for full deployment details: https://ucd.kp.org:8443/#applicationProcessRequest/$UCD_REQUEST_ID"
				fi
			fi
		done
	done
	[[ -f $app_name-$env_name.txt ]] && rm -f $app_name-$env_name.txt
	echo "UCD Deployment step complete"
else
	echo "No deployments initiated as no environments selected."
fi
