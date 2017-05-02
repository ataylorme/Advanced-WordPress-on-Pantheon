#!/bin/bash

###
# Restore the Pantheon site environment to the previous state after the Behat test suite has run.
###

# Log into terminus.
echo -e "\nLogging into Terminus"
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

# Check if logged into Terminus
TERMINUS_USER_ID=$(terminus auth:whoami --field=id 2>&1)
if [[ ! $TERMINUS_USER_ID =~ ^[A-Za-z0-9-]{36}$ ]]; then
	echo "Terminus unauthenticated; assuming unauthenticated build"
	exit 0
fi

if [ -z "$BEHAT_TEST_URL" ] || [ -z "$RUN_BEHAT_BUILD" ]; then
	echo "BEHAT_TEST_URL and RUN_BEHAT_BUILD environment variables must be set"
	exit 1
fi

if [ -z "$PANTHEON_SITE_UUID" ] || [ -z "$BEHAT_ENV" ]; then
	echo "PANTHEON_SITE_UUID and BEHAT_ENV environment variables must be set"
	exit 1
fi

set -ex

###
# Restore the backup of the environment from before Behat ran
###
terminus backup:restore $PANTHEON_SITE_UUID.$BEHAT_ENV --yes

###
# Delete existing WordPress admin user
###
echo "Deleting the WordPress user $WORDPRESS_ADMIN_USERNAME"
terminus wp $PANTHEON_SITE_UUID.$BEHAT_ENV -- user delete $WORDPRESS_ADMIN_USERNAME --yes
