#!/bin/bash

###
# Delete the Pantheon site environment after the Behat test suite has run.
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
	echo "TERMINUS_SITE and TERMINUS_ENV environment variables must be set"
	exit 1
fi

set -ex

###
# Delete the environment used for this test run.
###
terminus multidev:delete $PANTHEON_SITE_UUID.$BEHAT_ENV --delete-branch --yes
