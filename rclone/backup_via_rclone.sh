#!/bin/bash

docker run --rm --name rclone --env-file /home/${USERNAME}/docker/rclone/rclone.env -v /home/${USERNAME}/docker/rclone/config/:/root/.config/rclone/ -v /home/${USERNAME}/docker/rclone/backups:/backups openbridge/ob_bulkstash rclone --log-level INFO --transfers=32 --checkers=16 --drive-chunk-size=16384k --drive-upload-cutoff=16384k --stats 10s sync /backups/ gdrive:Backups/
