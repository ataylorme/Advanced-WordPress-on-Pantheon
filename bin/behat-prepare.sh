#!/bin/bash

###
# Prepare a Pantheon site environment for the Behat test suite, by installing
# and configuring the plugin for the environment. This script is architected
# such that it can be run a second time if a step fails.
###

# Log into terminus.
echo -e "\nLogging into Terminus"
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

terminus auth:whoami > /dev/null
if [ $? -ne 0 ]; then
	echo "Terminus unauthenticated; assuming unauthenticated build"
	exit 0
fi

if [ -z "$PANTHEON_SITE_UUID" ] || [ -z "$BEHAT_ENV" ]; then
	echo "PANTHEON_SITE_UUID and BEHAT_ENV environment variables must be set"
	exit 1
fi

if [ -z "$WORDPRESS_ADMIN_USERNAME" ] || [ -z "$WORDPRESS_ADMIN_PASSWORD" ]; then
	echo "WORDPRESS_ADMIN_USERNAME and WORDPRESS_ADMIN_PASSWORD environment variables must be set"
	exit 1
fi

set -ex

###
# Create a new environment for this particular test run.
###
echo "Creating multidev $BEHAT_ENV"
terminus multidev:create $PANTHEON_SITE_UUID.dev $BEHAT_ENV


###
# Set up WordPress admin user
###
{
  terminus wp $PANTHEON_SITE_UUID.$BEHAT_ENV -- user create $WORDPRESS_ADMIN_USERNAME no-reply@getpantheon.com --user_pass=$WORDPRESS_ADMIN_PASSWORD --role=administrator
} &> /dev/null
