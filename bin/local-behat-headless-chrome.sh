#!/bin/bash

# Start headless Chrome if needed
if [[ $(jobs | grep chrome) ]]
then
    jobs | grep chrome
    echo -e "\n Headless Chrome is already running ..."
else
    echo -e "\n Starting Chrome in headless mode ..."
    google-chrome-unstable --disable-gpu --headless --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --no-sandbox </dev/null &>/dev/null &
    jobs | grep chrome
    echo -e "\n Chrome started in headless mode ..."
fi

# Export the DB
./bin/export-db.sh

# Create the WordPress admin user
echo -e "\nCreating the WordPress admin user ..."
wp user create admin no-reply@pantheon.io --user_pass=admin --role=administrator

# Disable the lh-hsts plugin as it causes a redirect loop
echo -e "\nDeactivating the lh-hsts plugin ..."
wp plugin deactivate lh-hsts

# Run WordHat
./vendor/bin/behat --config=tests/behat/behat-lando.yml --strict

# Restore the DB
./bin/restore-db.sh