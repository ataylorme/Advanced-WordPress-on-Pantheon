#!/bin/bash

# Stash DB credentials
DB_USER=pantheon
DB_PASSWORD=pantheon
DB_HOST=database
DB_PORT=3306
DB_NAME=pantheon
DB_FILE_NAME="pre-behat-tests"

# Un-gzip the backup
gunzip $DB_FILE_NAME.sql.gz

# Build the SQL prefix
SQLSTART="mysql --user=$DB_USER --host=$DB_HOST --port=$DB_PORT --password=$DB_PASSWORD $DB_NAME"

# Get all the tables
DB_TABLES=$($SQLSTART -e 'SHOW TABLES' | awk '{ print $1}' | grep -v '^Tables' )

# Drop each tables
echo -e "\nDropping all the tables in the $DB_NAME database..."
for DB_TABLE in $DB_TABLES; do
    $SQLSTART -e "DROP TABLE $DB_TABLE"
done

# Import the DB
echo -e "\nImporting the $DB_NAME database..."
cat $DB_FILE_NAME.sql | $SQLSTART

# Remove the DB export file
echo -e "\nCleaning up the leftover $DB_FILE_NAME.sql ..."
if [ -f $DB_FILE_NAME.sql ]
then
    rm $DB_FILE_NAME.sql
fi