#!/bin/bash

###
# Execute the Behat test suite against a prepared Pantheon site environment.
###

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

export BEHAT_PARAMS='{"extensions" : {"Behat\\MinkExtension" : {"base_url" : "http://'$BEHAT_ENV'-'$PANTHEON_SITE_UUID'.pantheonsite.io"} }}'

./vendor/bin/behat "$@"
