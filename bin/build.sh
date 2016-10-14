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

COMPOSER_PARMS="--no-ansi --no-dev --no-interaction --optimize-autoloader --no-progress --no-scripts"

# Install Composer dependencies
echo -e "\n${txtylw}Invoking: $FOUND install $COMPOSER_PARMS ${txtrst}"
$FOUND install $COMPOSER_PARMS

echo -e "\n${txtylw}Creating web/wp-config.php ${txtrst}"
[ -f 'web/wp-config.php' ] && rm web/wp-config.php
cp wp-config.php web/wp-config.php
sed -i -e '$a\' web/wp-config.php
# Strip the first line to avoid the opening php tag
PANTHEON_WP_CONFIG_CONTENT="$(tail -n +2 web/wp/wp-config.php)"
echo "$PANTHEON_WP_CONFIG_CONTENT" >> web/wp-config.php

EXE=gulp

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo ${txtred}Error: executable gulp not found on path ${txtrst}
	exit 1
fi

# Look for gulpfile.js occurrences NOT in node_modules
echo -e "\n${txtylw}Looking for gulpfile.js occurrences NOT in node_modules.. ${txtrst}"
FILE=gulpfile.*js
for d in `find . \( -name node_modules -or -name components \) -prune -o -name "$FILE" | grep "$FILE"`
do
	# Change into containing directory
	echo -e "\n${txtylw}gulpfile found, changing directories into: ${d%/*} ${txtrst}"
	cd ${d%/*}

	# ~/node_modules is cached on Circles CI
	CURRENT_DIR=${PWD##*/}
	echo -e "\n${txtylw}Moving $HOME/node_modules/$CURRENT_DIR to node_modules${txtrst}"
	mkdir -p $HOME/node_modules/$CURRENT_DIR
	mv $HOME/node_modules/$CURRENT_DIR ./node_modules

	# Install any dependencies, if we find packages.json
	[ -f 'package.json' ] && echo -e "\n${txtylw}package.json found, running 'npm install' ${txtrst}"
	[ -f 'package.json' ] && npm install

	# Run gulp
	echo -e "\n${txtylw}Running 'gulp' ${txtrst}"
	$FOUND

	echo -e "\n${txtylw}Moving node_modules back to $HOME/node_modules/$CURRENT_DIR to cache it for next time${txtrst}"
	mv ./node_modules $HOME/node_modules/$CURRENT_DIR

	# Change back again
	echo -e "\n${txtylw}changed directories back into: ${txtrst}"
	cd -
done
