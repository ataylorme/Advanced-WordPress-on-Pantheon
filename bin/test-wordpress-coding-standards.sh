#!/bin/bash

# Add WordPress coding standards path to code sniffer
phpcs --config-set installed_paths $HOME/.composer/vendor/wp-coding-standards/wpcs

# Assume no errors
PHPCS_ERRORS = 0

# Change to project directory
cd $HOME/$CIRCLE_PROJECT_REPONAME

# Sniff all PHP files
find . -name '*.php' -print0 | while IFS= read -r -d $'\0' phpfile; do
    phpcs --standard=phpcs.ruleset.xml phpfile
	if [ "$?" != 0 ]
	then
		PHPCS_ERRORS = 0
	fi
done

if [ $PHPCS_ERRORS == 1 ]
then
	echo "\nPHPCS Failed. Please fix the error(s)."
	exit 1
fi

# Change directories back to wherever we were before
cd -