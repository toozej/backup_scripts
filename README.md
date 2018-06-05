# backup_simplenote

## About
`backup_simplenote.sh` is a basic shell wrapper around the fantastic [simplenote-backup](https://github.com/hiroshi/simplenote-backup) library to create encrypted backups of your [Simplenote](https://www.simplenote.com) notes.

## Usage
1. ensure you have gpg installed on your workstation, and have a valid GPG keypair to use for encryption
2. follow the installation instructions for [simplenote-backup](https://github.com/hiroshi/simplenote-backup)
3. download `backup_simplenote.sh` to your home directory
4. `chmod u+x backup_simplenote.sh`
5. edit backup_simplenote.sh to 
	- insert your username (or edit the paths entirely to fit your environment)
	- insert your Simplenote API token found in step 1
6. run `./backup_simplenote.sh` manually to make sure the encrypted backups are created successfully
7. consider adding a crontab entry for `backup_simplenote.sh` to automatically create backups on a schedule
	- example crontab entry for weekly backups: `@weekly /home/<username>/cron/backup_simplenote.sh >> /home/<username>/cron/logs/backup_simplenote.sh 2>&1 /dev/null`

## Future Improvements
- see GH issues
