#!/bin/bash

# Add WordPress coding standards path to code sniffer
phpcs --config-set installed_paths $HOME/.composer/vendor/wp-coding-standards/wpcs

# Change to project directory
cd $HOME/$CIRCLE_PROJECT_REPONAME

# Sniff all PHP files
phpcs --standard=phpcs.ruleset.xml $(find . -name '*.php')
if [ "$?" != 0 ]
then
	echo -e "\nPHPCS Failed. Please fix the error(s)."
	exit 1
fi

# Change directories back to wherever we were before
cd -

# Tell the user good job
echo -e "\nPHPCS Passed. Good job!"