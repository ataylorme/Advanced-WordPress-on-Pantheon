#!/bin/bash

###
# Prepare a Pantheon site environment for the Behat test suite, by installing
# and configuring the plugin for the environment. This script is architected
# such that it can be run a second time if a step fails.
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

###
# Create a new environment for this particular test run.
###
terminus multidev:create $PANTHEON_SITE_UUID.dev $BEHAT_ENV
terminus env:wipe $PANTHEON_SITE_UUID.$BEHAT_ENV

###
# Get all necessary environment details.
###
PANTHEON_GIT_URL="$(terminus connection:info $PANTHEON_SITE_UUID.$BEHAT_ENV --field=git_url)"
PANTHEON_SITE_URL="$BEHAT_ENV-$PANTHEON_SITE_UUID.pantheonsite.io"
PREPARE_DIR="/tmp/$BEHAT_ENV-$PANTHEON_SITE_UUID"
BASH_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###
# Switch to git mode for pushing the files up
###
terminus connection:info $PANTHEON_SITE_UUID.$BEHAT_ENV git
rm -rf $PREPARE_DIR
git clone -b $BEHAT_ENV $PANTHEON_GIT_URL $PREPARE_DIR

###
# Push files to the environment
###
cd $PREPARE_DIR
git add -A wp-content
git config user.email "solr-power@getpantheon.com"
git config user.name "Pantheon"
git commit -m "Include Solr Power"
git push

# Sometimes Pantheon takes a little time to refresh the filesystem
sleep 10

###
# Set up WordPress, theme, and plugins for the test run
###
{
  terminus wp $PANTHEON_SITE_UUID.$BEHAT_ENV -- core install --title="Pantheon WP Best Practices" --url=$PANTHEON_SITE_URL --admin_user=$WORDPRESS_ADMIN_USERNAME --admin_email=no-reply@getpantheon.com --admin_password=$WORDPRESS_ADMIN_PASSWORD
} &> /dev/null
