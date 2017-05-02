#!/bin/bash

TerminusAuth() {

	# Log into terminus.
	echo -e "\nLogging into Terminus..."
	terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

	# Check if logged into Terminus
	TERMINUS_USER_ID=$(terminus auth:whoami --field=id 2>&1)
	if [[ ! $TERMINUS_USER_ID =~ ^[A-Za-z0-9-]{36}$ ]]; then
		echo "Terminus unauthenticated; assuming unauthenticated build"
		exit 0
	fi

}