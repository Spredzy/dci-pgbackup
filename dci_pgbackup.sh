#!/bin/sh

source /etc/dci_pgbackup.conf

ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "PGPASSWORD=$PG_PASSWORD pg_dump $PG_DUMP_OPTS -U $PG_USER $PG_DATABASE" > $OUTPUT_DIR/$BACKUP_FILENAME
ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "PGPASSWORD=$PG_PASSWORD pg_dumpall --globals-only" > $OUTPUT_DIR/$BACKUP_GLOBALS

ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "echo \"jobs,\$(psql -U $PG_USER -d $PG_DATABASE -c 'COPY (SELECT COUNT(*) FROM jobs) TO STDOUT')\"" > $OUTPUT_DIR/$BACKUP_RESULTS
ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "echo \"users,\$(psql -U $PG_USER -d $PG_DATABASE -c 'COPY (SELECT COUNT(*) FROM users) TO STDOUT')\"" >> $OUTPUT_DIR/$BACKUP_RESULTS
ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "echo \"remotecis,\$(psql -U $PG_USER -d $PG_DATABASE -c 'COPY (SELECT COUNT(*) FROM remotecis) TO STDOUT')\"" >> $OUTPUT_DIR/$BACKUP_RESULTS
ssh -o "Compression=no" -o "StrictHostKeyChecking=no" $SSH_USER@$SSH_IP "echo \"teams,\$(psql -U $PG_USER -d $PG_DATABASE -c 'COPY (SELECT COUNT(*) FROM teams) TO STDOUT')\"" >> $OUTPUT_DIR/$BACKUP_RESULTS
