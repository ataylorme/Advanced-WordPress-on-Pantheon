#!/bin/bash

# Stash DB credentials
DB_USER=pantheon
DB_PASSWORD=pantheon
DB_HOST=database
DB_PORT=3306
DB_NAME=pantheon
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
echo "\nExporting the $DB_NAME database to $DB_FILE_NAME.sql ..."
mysqldump --opt --user=$DB_USER --host=$DB_HOST --port=$DB_PORT --password=$DB_PASSWORD $DB_NAME > $DB_FILE_NAME.sql

# gzip the backup file
echo "\nGzipping $DB_FILE_NAME.sql ..."
gzip $DB_FILE_NAME.sql

# Create the WordPress admin user
echo "\nCreating the WordPress admin user ..."
wp user create admin no-reply@pantheon.io --user_pass=admin --role=administrator

# Disable the lh-hsts plugin as it causes a redirect loop
wp plugin deactivate lh-hsts

# Run WordHat
./vendor/bin/behat --config=tests/behat/behat-lando.yml --strict

# Restore the DB

# Un-gzip the backup
gunzip $DB_FILE_NAME.sql.gz

# Build the SQL prefix
SQLSTART="mysql --user=$DB_USER --host=$DB_HOST --port=$DB_PORT --password=$DB_PASSWORD $DB_NAME"

# Get all the tables
DB_TABLES=$($SQLSTART -e 'SHOW TABLES' | awk '{ print $1}' | grep -v '^Tables' )

# Drop each tables
echo "\nDropping all the tables in the $DB_NAME database..."
for DB_TABLE in $DB_TABLES; do
    $SQLSTART -e "DROP TABLE $DB_TABLE"
done

# Import the DB
echo "\nImporting the $DB_NAME database..."
cat $DB_FILE_NAME.sql | $SQLSTART

# Remove the DB export file
echo "\nCleaning up the leftover $DB_FILE_NAME.sql ..."
if [ -f $DB_FILE_NAME.sql ]
then
    rm $DB_FILE_NAME.sql
fi