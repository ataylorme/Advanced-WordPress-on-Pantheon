#!/bin/bash

#
# Install Dependencies With Composer
#

JSON=composer.json
EXE=composer

# CI options
export COMPOSER_DISCARD_CHANGES=1
export COMPOSER_NO_INTERACTION=1

if [ ! -f "$JSON" ]
then
	echo Error: No $JSON found
	exit 1
fi

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo Error: executable composer not found on path
	exit 1
fi

COMPOSER_PARMS="--no-ansi --no-interaction --optimize-autoloader --no-progress"

# Install Composer dependencies
echo -e "\nInvoking: $FOUND install $COMPOSER_PARMS"
$FOUND install $COMPOSER_PARMS

# Copy Pantheon mu-plugins
if [ -d 'web/wp/wp-content/mu-plugins/' ]
then
	echo -e "\nCopying Pantheon mu-plugins"
	rsync -a web/wp/wp-content/mu-plugins/* web/wp-content/mu-plugins/
fi

# Remove wp-content and wp-config from wp subdirectory
echo -e "\nRemoving wp-content and wp-config from wp subdirectory"
[ -f 'web/wp/wp-config.php' ] && rm -rf ./web/wp/wp-config.php
[ -d 'web/wp/wp-content' ] && rm -rf ./web/wp/wp-content
