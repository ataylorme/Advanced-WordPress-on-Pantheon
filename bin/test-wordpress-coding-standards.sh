#!/bin/bash
BUILD_DIR=$(pwd)

# Add WordPress coding standards path to code sniffer
./vendor/bin/phpcs --config-set installed_paths $HOME/.composer/vendor/wp-coding-standards/wpcs

# Code sniff custom mu-plugin PHP files
./vendor/bin/phpcs --standard=phpcs.ruleset.xml ./web/wp-content/mu-plugins/alter-wpcfm-config-path.php

# Code sniff custom theme PHP files
./vendor/bin/phpcs --standard=phpcs.ruleset.xml $(find ./web/wp-content/themes/twentyseventeen-child -type f -name '*.php')
if [ "$?" != 0 ]
then
	echo -e "\nPHPCS Failed. Please fix the error(s)."
	exit 1
fi

# Tell the user good job
echo -e "\nPHPCS Passed. Good job!"
