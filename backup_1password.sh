#!/bin/bash

# get today's date
_NOW=$(date +"%m_%d_%Y")

# variables

function signin {
    # Get current account from op config
    if [ -f "$HOME/.op/config" ]; then
        ACCOUNT=$(jq '.accounts | .[] | .shorthand' "$HOME/.op/config" --raw-output)
        echo $(op signin "${ACCOUNT}")
    else
        op "$@"
    fi
}

function export_logins {
    ITEMS=$(op list items)
    UUIDS=($(echo "${ITEMS}" | jq '.[] | .uuid' --raw-output))
    ITEMS=()

    echo -ne "Exporting data (this may take a while)..."
    for UUID in ${UUIDS[@]}; do
        ITEMS+=($(op get item "${UUID}"))
        if [ $? -ne 0 ]; then
            FAILED="${FAILED} exporting ${UUID} from 1Password failed on ${_NOW}\n"
        fi
        # sleep as to not trigger rate limiter
        sleep 0.5
    done
}

function import_login {
    # create pass item
    # might need to split ITEM into username, password, url, notes, etc.
    pass import ${FOLDER}/${NAME}
}

function create_csv_file {
    CSV_FILENAME="${BACKUP_PATH}/1password_backup_${_NOW}.csv"
    touch ${CSV_FILENAME} && chmod 0600 ${CSV_FILENAME}
    if [ $? -ne 0 ]; then
        FAILED="${FAILED} creating csv file ${CSV_FILENAME} failed on ${_NOW}\n"
    fi
}

function write_csv_login {
    # creates CSV row from item in the following format:
    # url,username,password,[... more fields]
}

# help/usage information
function usage {
    echo "Usage: backup_1password.sh [-c] [-p] [-d]"
    echo ""
    echo "  -h                  Display usage."
    echo ""
    echo "  -c                  Export 1password logins to CSV file."
    echo ""
    echo "  -p                  Export 1password logins to pass database."
    echo ""
    echo "  -d                  Enable debug output."
    echo ""
}

function set_defaults {
    CSV=false
    PASS=false
    DEBUG=false
    USERNAME=my_unix_username_here
    EMAIL="me@example.com"
    BACKUP_PATH=passwords_${_NOW}
    FAILED=''
}

# set defaults before getting user input
set_defaults

# get user input
while getopts ":hc:p:d:" option
do
  case $option in
    h)
      usage
      exit 1
      ;;
    c)
      CSV=true
      ;;
    p)
      PASS=true
      ;;
    d)
      DEBUG=true
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

cd ${BACKUP_PATH}
signin
if [ $? -ne 0 ]; then
    FAILED="${FAILED} logging into 1Password failed on ${_NOW}\n"
    exit 1
fi

if [[ $CSV == "true" && $PASS == "false" && $DEBUG == "false" ]]; then
    create_csv_file()
    if [ $? -ne 0 ]; then
        FAILED="${FAILED} creating csv password backup file failed on ${_NOW}\n"
        exit 1
    fi
    for ITEM in export_logins; do
        write_csv_login(${ITEM})
        if [ $? -ne 0 ]; then
            FAILED="${FAILED} writing ${ITEM} to csv file failed ${_NOW}\n"
        fi
    done
elif [[ $CSV == "true" && $PASS == "false" && $DEBUG == "true" ]]; then
    echo "creating csv"
    create_csv_file()
    if [ $? -ne 0 ]; then
        FAILED="${FAILED} creating csv password backup file failed on ${_NOW}\n"
        exit 1
    fi
    echo "creating csv password backup file successful"
    echo "cycling through exported 1password items"
    for ITEM in export_logins; do
        echo "writing item ${ITEM} into csv file"
        write_csv_login(${ITEM})
        if [ $? -ne 0 ]; then
            FAILED="${FAILED} writing ${ITEM} to csv file failed ${_NOW}\n"
        fi
    done
    echo "completed backing up to csv file"
elif [[ $CSV == "false" && $PASS == "true" && $DEBUG == "false" ]]; then
    pass init -p ${BACKUP_PATH} ${EMAIL} && pass git init
    if [ $? -ne 0 ]; then
        FAILED="${FAILED} creating backup password store failed on ${_NOW}\n"
        exit 1
    fi
    for ITEM in export_logins; do
        import_login(${ITEM})
        if [ $? -ne 0 ]; then
            FAILED="${FAILED} importing ${ITEM} to pass failed ${_NOW}\n"
        fi
    done
elif [[ $CSV == "false" && $PASS == "true" && $DEBUG == "true" ]]; then
    echo "initializing pass store"
    pass init -p ${BACKUP_PATH} ${EMAIL} && pass git init ${BACKUP_PATH}
    if [ $? -ne 0 ]; then
        FAILED="${FAILED} creating backup password store failed on ${_NOW}\n"
        exit 1
    fi
    echo "initializing pass store successful"
    echo "cycling through exported 1password items"
    for ITEM in export_logins; do
        echo "importing item ${ITEM} into pass store"
        import_login(${ITEM})
        if [ $? -ne 0 ]; then
            FAILED="${FAILED} importing ${ITEM} to pass failed ${_NOW}\n"
        fi
    done
    echo "completed backing up to password store"
else
    echo "invalid input parameters"
    FAILED="${FAILED} invalid input parameters, failed on ${_NOW}\n"
    usage()
fi


if [ -n "${FAILED}" ]; then
    # pushbullet notification for failed backup with ${FAILED} contents
    BODY="1Password backup failed with output: ${FAILED}"
    STATUS="Failed"
else
    # pushbullet notification for successful backup
    BODY="1Password backup finished successfully on ${_NOW}"
    STATUS="Successful"
fi

TITLE="1Password Backup '${STATUS}' on '$(hostname)'"

# uses https://github.com/toozej/pushbullet_notifier/blob/master/pb_notifier.sh
# for notifying of success/failure via Pushbullet
# make sure to download the pb_notifier.sh script somewhere you can run it,
# and insert your Pushbullet access token in the variable ACCESS_TOKEN
source /home/$USERNAME/path/to/pb_notifier.sh ${EMAIL} ${TITLE} ${BODY}
