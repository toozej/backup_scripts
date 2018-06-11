# backup_scripts
A collection of backup scripts for various things. These scripts are fairly similar and all create encrypted backups (and eventually notify on success/failure via Pushbullet)

## backup_simplenote
### About
`backup_simplenote.sh` is a basic shell wrapper around the fantastic [simplenote-backup](https://github.com/hiroshi/simplenote-backup) library to create encrypted backups of your [Simplenote](https://www.simplenote.com) notes.

### Usage
1. ensure you have gpg installed on your workstation, and have a valid GPG keypair to use for encryption
2. follow the installation instructions for [simplenote-backup](https://github.com/hiroshi/simplenote-backup)
3. clone this repo or download `backup_simplenote.sh` to your home directory
4. edit `backup_simplenote.sh` to 
	- insert your username (or edit the paths entirely to fit your environment)
	- insert your Simplenote API token found in step 1
5. run `./backup_simplenote.sh` manually to make sure the encrypted backups are created successfully
6. consider adding a crontab entry for `backup_simplenote.sh` to automatically create backups on a schedule
	- example crontab entry for weekly backups: `@weekly /home/<username>/cron/backup_simplenote.sh >> /home/<username>/cron/logs/backup_simplenote.log 2>&1 /dev/null`


## backup_docker
### About
`backup_docker.sh` is a shell script to create encrypted backups of Docker-Compose projects which are stored under `/home/<username>/Docker/<project_name>/` containing files such as `docker-compose.yml`, configuration files, and any mounted storage volumes.

### Usage
1. ensure you have gpg installed on your workstation, and have a valid GPG keypair to use for encryption
2. clone this repo or download `backup_docker.sh` to your home directory
3. edit `backup_docker.sh` to 
	- insert your username (or edit the paths entirely to fit your environment)
	- insert your Pushbullet API token
4. run `sudo ./backup_docker.sh` manually to make sure the encrypted backups are created successfully
5. consider adding a crontab entry for `backup_docker.sh` to automatically create backups on a schedule
	- example crontab entry for weekly backups: `@weekly /home/<username>/cron/backup_docker.sh >> /home/<username>/cron/logs/backup_docker.log 2>&1 /dev/null`


## backup_vm
### About
Coming soon...

### Usage
