#!/bin/bash

# Stash DB name
DB_FILE_NAME="pre-behat-tests"

# Export the DB

# Remove old DB export files if they exists
if [ -f $DB_FILE_NAME.sql ]
then
    rm $DB_FILE_NAME.sql
fi

if [ -f $DB_FILE_NAME.sql.gz ]
then
    rm $DB_FILE_NAME.sql.gz
fi

# Dump the current DB
echo -e "\nExporting the $DB_NAME database to $DB_FILE_NAME.sql ..."
mysqldump --opt --user=$DB_USER --host=$DB_HOST --port=$DB_PORT --password=$DB_PASSWORD $DB_NAME > $DB_FILE_NAME.sql

# gzip the backup file
echo -e "\nGzipping $DB_FILE_NAME.sql ..."
gzip $DB_FILE_NAME.sql