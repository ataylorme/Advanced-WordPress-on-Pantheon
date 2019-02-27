#!/bin/bash

# Export the DB
./bin/export-db.sh

# Set up variables
export BEHAT_ADMIN_PASSWORD=$(openssl rand -base64 24)
export BEHAT_ADMIN_EMAIL=andrew+local-ci@pantheon.io
export BEHAT_ADMIN_USERNAME=pantheon-ci-testing-local

# Check if an admin user with our desired username exists
export BEHAT_ADMIN_USER_EXISTS=$(wp user list --login=${BEHAT_ADMIN_USERNAME} --format=count)

# Create the admin user if needed
if [[ "$BEHAT_ADMIN_USER_EXISTS" == "0" ]]
then
  echo -e "\nCreating the WordPress admin user ..."
  wp user create $BEHAT_ADMIN_USERNAME $BEHAT_ADMIN_EMAIL --user_pass=$BEHAT_ADMIN_PASSWORD --role=administrator
fi

echo -e "\n WordPress user $BEHAT_ADMIN_USERNAME with the password $BEHAT_ADMIN_PASSWORD has been created."

# Set Behat variables from environment variables
export RELOCATED_WP_ADMIN=TRUE

# Dynamically set Behat configuration parameters
export BEHAT_PARAMS='{"extensions":{"Behat\\MinkExtension":{"base_url":"https://edge_ssl.pantheonwpbestpractices.internal/"},"PaulGibbs\\WordpressBehatExtension":{"site_url":"https://edge_ssl.pantheonwpbestpractices.internal/wp","users":{"admin":{"username":"'$BEHAT_ADMIN_USERNAME'","password":"'$BEHAT_ADMIN_PASSWORD'"}},"wpcli":{"binary":"wp"}}}}'

export LANDO_BEHAT=1

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

# Run WordHat
./vendor/bin/behat --config=tests/behat/behat-pantheon.yml --strict --colors --format-settings='{"paths": false}'

# Restore the DB
./bin/restore-db.sh