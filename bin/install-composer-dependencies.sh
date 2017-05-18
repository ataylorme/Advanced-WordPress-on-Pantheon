#!/bin/bash

#
# Build script
#
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.


JSON=composer.json
EXE=composer

# CI options
export COMPOSER_DISCARD_CHANGES=1
export COMPOSER_NO_INTERACTION=1

if [ ! -f "$JSON" ]
then
	echo ${txtred}Error: No $JSON found ${txtrst}
	exit 1
fi

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo ${txtred}Error: executable composer not found on path ${txtrst}
	exit 1
fi

COMPOSER_PARMS="--no-ansi --no-interaction --optimize-autoloader --no-progress --no-scripts"

# Install Composer dependencies
echo -e "\n${txtylw}Invoking: $FOUND install $COMPOSER_PARMS ${txtrst}"
$FOUND install $COMPOSER_PARMS

# Copy Pantheon mu-plugins
if [ -d 'web/wp/wp-content/mu-plugins/' ]
then
	echo -e "\n${txtylw}Copying Pantheon mu-plugins ${txtrst}"
	rsync -a web/wp/wp-content/mu-plugins/* web/wp-content/mu-plugins/
fi

# Remove wp-content and wp-config from wp subdirectory
echo -e "\n${txtylw}Removing wp-content and wp-config from wp subdirectory ${txtrst}"
[ -f 'web/wp/wp-config.php' ] && rm -rf ./web/wp/wp-config.php
[ -d 'web/wp/wp-content' ] && rm -rf ./web/wp/wp-content