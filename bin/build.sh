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

# Copy Pantheon mu-plugins
echo -e "\n${txtylw}Copying Pantheon mu-plugins ${txtrst}"
rsync -a web/wp/wp-content/mu-plugins/* web/wp-content/mu-plugins/

# Remove wp-content and wp-config from wp subdirectory
echo -e "\n${txtylw}Removing wp-content and wp-config from wp subdirectory ${txtrst}"
[ -f 'web/wp/wp-config.php' ] && rm -rf ./web/wp/wp-config.php
[ -d 'web/wp/wp-content' ] && rm -rf ./web/wp/wp-content

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

	# Install any dependencies, if we find packages.json
	[ -f 'package.json' ] && echo -e "\n${txtylw}package.json found, running 'yarn install' ${txtrst}"
	[ -f 'package.json' ] && yarn install

	# Run gulp
	echo -e "\n${txtylw}Running 'gulp' ${txtrst}"
	$FOUND

	# Change back again
	echo -e "\n${txtylw}changed directories back into: ${txtrst}"
	cd -
done
