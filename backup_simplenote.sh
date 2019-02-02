#!/bin/bash

# get today's date
_now=$(date +"%m_%d_%Y")

# variables
TMP_PATH=/home/$USERNAME/Backups/simplenote_tmp
BINARY_PATH=/home/$USERNAME/bin/simplenote-backup
BACKUP_PATH=/home/$USERNAME/Backups/simplenote
TAR_FILE_NAME=simplenote_$_now.tgz
FAILED=''
USERNAME=my_unix_username
EMAIL="me@example.com"

# make temp directory for dumps of simplenote notes
mkdir ${TMP_PATH}

# dump simplenote notes into temp directory
cd ${BINARY_PATH}
make TOKEN=<simplenote_token_goes_here> BACKUP_DIR=${TMP_PATH}

# create tar of simplenote notes suffixed with today's date
tar -cvzf  ${BACKUP_PATH}/${TAR_FILE_NAME} ${TMP_PATH}
if [ $? -eq 0 ]; then
	echo "tar-ing simplenote backups on $_now completed successfully, removing tmp files"
	rm -rf ${TMP_PATH}
else
	FAILED="${FAILED} error tar-ing simplenote backups on $_now"
fi

# only attempt to encrypt tar if last step passed
if [ -z "${FAILED}" ]; then
    # encrypt the tar of simplenote notes
    gpg --homedir /home/$USERNAME/.gnupg --trust-model always --output ${BACKUP_PATH}/${TAR_FILE_NAME}.gpg --encrypt --recipient "${EMAIL}" ${BACKUP_PATH}/${TAR_FILE_NAME}
    if [ $? -eq 0 ]; then
        echo "encrypting simplenote backups on $_now completed successfully, removing unencrypted tar file"
        shred ${BACKUP_PATH}/${TAR_FILE_NAME} && rm -f ${BACKUP_PATH}/${TAR_FILE_NAME}
    else
		FAILED="${FAILED} error encrypting simplenote backups on $_now"
    fi
fi

if [ -n "${FAILED}" ]; then
        BODY="Simplenote backup failed with output: ${FAILED}"
        STATUS="Failed"
else
        BODY="Simplenote backup finished successfully on ${_now}"
        STATUS="Successful"
fi

TITLE="Simplenote Backup '${STATUS}' on '${HOSTNAME}'"

# uses https://github.com/toozej/pushbullet_notifier/blob/master/pb_notifier.sh
# for notifying of success/failure via Pushbullet
# make sure to download the pb_notifier.sh script somewhere you can run it,
# and insert your Pushbullet access token in the variable ACCESS_TOKEN
source /home/$USERNAME/path/to/pb_notifier.sh ${EMAIL} ${TITLE} ${BODY}
