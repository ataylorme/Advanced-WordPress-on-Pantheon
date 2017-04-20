#!/bin/bash

###
# Execute the Behat test suite against a prepared Pantheon site environment.
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

PANTHEON_SITE_NAME="$(terminus site:info $PANTHEON_SITE_UUID --fields=name --format=string)"

export BEHAT_PARAMS='{"extensions" : {"Behat\\MinkExtension" : {"base_url" : "https://'$BEHAT_ENV'-'$PANTHEON_SITE_NAME'.pantheonsite.io"} }}'

./vendor/bin/behat "$@"