#!/bin/bash

# get today's date
_NOW=$(date +"%m_%d_%Y")

# variables
BACKUP_PATH=/home/<username>/Backups/docker
FAILED=''
ACCESS_TOKEN="<Pushbullet access token goes here>"

for DIR in `find /home/<username>/docker/ -mindepth 1 -maxdepth 1 -type d`; do
	echo "working on: ${DIR}"

	# don't back up docker containers that have a .do_not_backup file
	if [ -e "${DIR}/.do_not_backup" ]; then
		echo "skipping backing up ${DIR}"
		continue
	fi

	TAR_FILE_NAME="$(basename ${DIR})_${_NOW}.tgz"

	# shutdown running docker container
	docker-compose -f ${DIR}/docker-compose.yml down
	if [ $? -ne 0 ]; then
		FAILED="${FAILED} shutting down ${DIR} docker container failed on ${_NOW}\n"
		# skip to next ${DIR}
		continue
	fi

	# tar.gz the directory
	tar -czf ${TAR_FILE_NAME} ${DIR}
	if [ $? -ne 0 ]; then
		FAILED="${FAILED} tarring ${DIR} docker container failed on ${_NOW}\n"
	fi

	# start docker container
	docker-compose -f ${DIR}/docker-compose.yml up -d
	if [ $? -ne 0 ]; then
		FAILED="${FAILED} starting ${DIR} docker container failed on ${_NOW}\n"
	fi

	# gpg encrypt the tgz
	gpg --batch --yes --homedir /home/<username>/.gnupg --trust-model always --output ${BACKUP_PATH}/${TAR_FILE_NAME}.gpg --encrypt --recipient "<username>@example.com" ${TAR_FILE_NAME}
	if [ $? -eq 0 ]; then
		echo "encrypting ${DIR} docker backup on ${_NOW} completed successfully, removing unencrypted tar file"
		shred ${TAR_FILE_NAME} && rm -f ${TAR_FILE_NAME}
		if [ $? -ne 0 ]; then
			FAILED="${FAILED} destroying ${TAR_FILE_NAME} failed on ${_NOW}\n"
		fi
	else
		FAILED="${FAILED} error encrypting ${DIR} docker backup on ${_NOW}\n"
	fi

done

if [ -n "${FAILED}" ]; then
	# pushbullet notification for failed backup with ${FAILED} contents
	BODY="Docker backup failed with output: ${FAILED}"
	STATUS="Failed"
else
	# pushbullet notification for successful backup
	BODY="Docker backup finished successfully on ${_NOW}"
	STATUS="Successful"
fi

curl --header 'Access-Token: '"${ACCESS_TOKEN}"'' \
	--header 'Content-Type: application/json' \
	--data-binary '{"body":"'"${BODY}"'","email":"<username>@example.com","title":"Docker Backup '${STATUS}' on '$(hostname)'","type":"note"}' \
	--request POST \
	https://api.pushbullet.com/v2/pushes > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Pushbullet notification failed. Here is what it would have said: ${STATUS} ${BODY}"
fi
