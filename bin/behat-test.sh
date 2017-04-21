#!/bin/bash

###
# Execute the Behat test suite against a prepared Pantheon site environment.
###

if [ -z "$BEHAT_TEST_URL" ] || [ -z "$RUN_BEHAT_BUILD" ]; then
	echo "BEHAT_TEST_URL and RUN_BEHAT_BUILD environment variables must be set"
	exit 1
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

export BEHAT_PARAMS='{"extensions" : {"Behat\\MinkExtension" : {"base_url" : "'$BEHAT_TEST_URL'"} }}'

./vendor/bin/behat "$@"