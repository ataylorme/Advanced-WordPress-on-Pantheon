#!/bin/bash
if [ ! -d "$HOME/terminus" ]
then
	# Clone terminus if it doesn't exist
	echo -e "Installing Terminus...\n"
	git clone --branch master https://github.com/pantheon-systems/terminus.git ~/terminus
	cd "$HOME/terminus"
	composer install
	cd -
else
	# Otherwise make sure terminus is up to date
	cd "$HOME/terminus"
	git pull
	cd -
fi

# Add terminus to path
export PATH="$PATH:/install/location/terminus/bin"