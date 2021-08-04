# backup_scripts
A collection of backup scripts for various things. These scripts are fairly similar and all create encrypted backups (and eventually notify on success/failure via Pushbullet)

## pre-requisites
All backup_scripts use the `pb_notifier.sh` script as part of [my Pushbullet notifier library for Bash](https://github.com/toozej/pushbullet_notifier). You will need to download `pb_notifier.sh` into a path you have access to before using the backup_scripts. For example, `wget https://raw.githubusercontent.com/toozej/pushbullet_notifier/master/pb_notifier.sh ~/bin/pb_notifier.sh` will download the latest version to your `~/bin` directory. You will then just need to add your Pushbullet access token to `pb_notifier.sh` ACCESS_TOKEN variable and away you go.

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

## backup_1password
### About
`backup_1password.sh` is a shell script to create export 1Password entries and either export them to a csv file or store them in a `pass` vault, which itself uses GPG as an encrypted password manager. The `pass` vault is stored at `/home/<username>/Backups/passwords/`.

### Usage
1. ensure you have `op` 1Password CLI and `pass` Password Manager installed
2. clone this repo or download `backup_1password.sh` to your home directory
3. edit `backup_1password.sh` to
	- insert your username (or edit the paths entirely to fit your environment)
	- insert your Pushbullet API token
4. login to `op`
5. run `./backup_1password.sh` manually to make sure the backup is created successfully
6. consider adding a crontab entry for `backup_1password.sh` to automatically create backups on a schedule
	- example crontab entry for weekly backups: `@weekly /home/<username>/cron/backup_1password.sh >> /home/<username>/cron/logs/backup_1password.log 2>&1 /dev/null`


## backup_vm
### About
Coming soon...

### Usage
