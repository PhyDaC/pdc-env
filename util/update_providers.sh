#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Script requires a providers.csv file be provided as an argument!"
	echo "No changes made, exiting..."
	exit
fi

OLDIFS=$IFS #store old file seperator just in case.
IFS=","  #set our file seperator to comma

GROUPS_FILE="/pdc/data/config/groups/groups.json"
JURI="TEST"

count=0
provider_hash=0

while read username cpsid group attachment pphrr populationhealth practicereflection
do
	# do not count the first line.

	if [ $count == 0 ]; then
		count=$((count+1))
		continue
	fi

	# get the hash for the provider.

	provider_hash=`echo -n "$cpsid" | openssl dgst -binary -sha224 | openssl base64`

	echo $count":"$username","$cpsid","$group","$provider_hash


	#update the groups.json for providers
	sudo ./add_user_to_group.py $provider_hash "\""$group"\"" $GROUPS_FILE

	#update the user in dacs
	sudo docker exec auth /app/manage_users.sh $username $provider_hash $group $JURI

	#update the user to filter providers function in queries via the HAPI container.
	if [ $attachment != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash Attachment 
	fi
	if [ $pphrr != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PPhRR 
	fi
	if [ $populationhealth != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PopulationHealth 
	fi
	if [ $practicereflection != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PracticeReflection
	fi

	count=$((count+1))

done < $1

IFS=$OLDIFS # make sure we set the file seperator back.