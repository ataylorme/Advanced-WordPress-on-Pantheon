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
VENDOR=./vendor
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

COMPOSER_PARMS="--no-ansi --no-dev --no-interaction --optimize-autoloader --no-progress"

# Install Composer dependencies
echo -e "\n${txtylw} Invoking: $FOUND install $COMPOSER_PARMS ${txtrst}"
$FOUND install $COMPOSER_PARMS

EXE=gulp

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo ${txtred}Error: executable gulp not found on path ${txtrst}
	exit 1
fi

# Look for gulpfile.js occurrences NOT in node_modules
FILE=gulpfile.*js
for d in `find . \( -name node_modules -or -name components \) -prune -o -name "$FILE" | grep "$FILE"`
do
	# Change into containing directory
	echo -e "\n${txtylw}gulpfile found, changing directories into: ${d%/*} ${txtrst}"
	cd ${d%/*}

	# Create symlink to ~/node_modules, which is cached
	CURRENT_DIR=${PWD##*/}
	echo -e "\n${txtylw}Creating symlink to $HOME/node_modules/$CURRENT_DIR ${txtrst}"
	ln -s $HOME/node_modules/$CURRENT_DIR ./node_modules

	# Install any dependencies, if we find packages.json
	echo -e "\n${txtylw}package.json found, running 'npm install' ${txtrst}"
	[ -f 'package.json' ] && npm install

	# Run gulp
	echo -e "\n${txtylw}Running 'gulp' ${txtrst}"
	$FOUND

	echo -e "\n${txtylw}Removing 'node_modules' ${txtrst}"
	rm -rf node_modules

	# Change back again
	echo -e "\n${txtylw}changed directories back into: ${txtrst}"
	cd -
done
