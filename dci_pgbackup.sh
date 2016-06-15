#!/bin/sh

source /etc/dci_pgbackup.conf

if [ $# -eq 1 -a "$1" == "--daily" ]; then
  DUMP_NAME=$(date +%Y%m%d)_dci_backup.sql
  PSEUDO_FOLDER='dci_daily_db_backup'
else
  DUMP_NAME=$(rpm -q --queryformat '%{VERSION}' dci-api | sed 's/[0-9].[0-9].\(.*\)/\1/g').sql
  PSEUDO_FOLDER='dci_commit_db_backup'
fi

# Check dependencies, exit if missing
DEPENDENCIES='pg_dump swift'
for dep in $DEPENDENCIES; do
    which $dep 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "The $dep program is not installed it is required to run properly"
        exit 1
    fi
done


# If an SCL is installed, enable it
if [ -d /opt/rh/rh-postgresql94 ]; then
  . /opt/rh/rh-postgresql94/enable
fi


# Do the actual backup of the database
if [ -d $OUTPUT_DIR ]; then
  mkdir -p $OUTPUT_DIR
fi

PGPASSWORD=$PG_PASSWORD pg_dump -Z9 -Fc -U $PG_USER -h $PG_HOST -w $PG_DATABASE > $OUTPUT_DIR/$DUMP_NAME
PGPASSWORD=$PG_PASSWORD pg_dumpall --globals-only $OUTPUT_DIR/globals_$DUMP_NAME


# Check if the container exists, else create it
swift list $CONTAINER > /dev/null
if [ $? -ne 0 ]; then
  swift post $CONTAINER
fi


# Upload the backup
swift list $CONTAINER | grep "$PSEUDO_FOLDER/$DUMP_NAME" > /dev/null
if [ $? -ne 0 ]; then
  pushd $OUTPUT_DIR > /dev/null
  swift upload $CONTAINER --object-name $PSEUDO_FOLDER/$DUMP_NAME $DUMP_NAME > /dev/null
  swift upload $CONTAINER --object-name $PSEUDO_FOLDER/globals_$DUMP_NAME globals_$DUMP_NAME > /dev/null
  rm -rf $OUTPUT_DIR/$DUMP_NAME
  if [ $? -eq 0 ]; then
    echo "$DUMP_NAME successfully uploaded to the object store"
  else
    echo "Something wrong happened during upload of $DUMP_NAME"
    exit 1
  fi
  popd > /dev/null
fi
