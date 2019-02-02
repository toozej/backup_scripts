#!/bin/bash

# get today's date
_NOW=$(date +"%m_%d_%Y")

# variables
USERNAME=my_unix_username_here
EMAIL="me@example.com"
BACKUP_PATH=/home/$USERNAME/Backups/docker
FAILED=''


for DIR in `find /home/$USERNAME/docker/ -mindepth 1 -maxdepth 1 -type d`; do
	echo "working on: ${DIR}"

	# don't back up docker containers that have a .do_not_backup file
	if [ -e "${DIR}/.do_not_backup" ]; then
		echo "skipping backing up ${DIR}"
		continue
	fi

	TAR_FILE_NAME="$(basename ${DIR})_${_NOW}.tgz"

	# shutdown running docker container
	/usr/local/bin/docker-compose -f ${DIR}/docker-compose.yml down
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
	/usr/local/bin/docker-compose -f ${DIR}/docker-compose.yml up -d
	if [ $? -ne 0 ]; then
		FAILED="${FAILED} starting ${DIR} docker container failed on ${_NOW}\n"
	fi

	# gpg encrypt the tgz
	gpg --batch --yes --homedir /home/$USERNAME/.gnupg --trust-model always --output ${BACKUP_PATH}/${TAR_FILE_NAME}.gpg --encrypt --recipient ${EMAIL} ${TAR_FILE_NAME}
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

TITLE="Docker Backup '${STATUS}' on '$(hostname)'"

# uses https://github.com/toozej/pushbullet_notifier/blob/master/pb_notifier.sh
# for notifying of success/failure via Pushbullet
# make sure to download the pb_notifier.sh script somewhere you can run it,
# and insert your Pushbullet access token in the variable ACCESS_TOKEN
source /home/$USERNAME/path/to/pb_notifier.sh ${EMAIL} ${TITLE} ${BODY}
