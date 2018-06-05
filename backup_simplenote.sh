#!/bin/bash

# get today's date
_now=$(date +"%m_%d_%Y")

# variables
TMP_PATH=/home/<username>/Backups/simplenote_tmp
BINARY_PATH=/home/<username>/bin/simplenote-backup
BACKUP_PATH=/home/<username>/Backups/simplenote
TAR_FILE_NAME=simplenote_$_now.tgz

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
	echo "error tar-ing simplenote backups on $_now"
	exit 1
fi

# encrypt the tar of simplenote notes
gpg --homedir /home/<username>/.gnupg --trust-model always --output ${BACKUP_PATH}/${TAR_FILE_NAME}.gpg --encrypt --recipient "<username>@example.com" ${BACKUP_PATH}/${TAR_FILE_NAME}
if [ $? -eq 0 ]; then
	echo "encrypting simplenote backups on $_now completed successfully, removing unencrypted tar file"
	shred ${BACKUP_PATH}/${TAR_FILE_NAME} && rm -f ${BACKUP_PATH}/${TAR_FILE_NAME}
	exit 0
else
	echo "error encrypting simplenote backups on $_now"
	exit 2
fi
