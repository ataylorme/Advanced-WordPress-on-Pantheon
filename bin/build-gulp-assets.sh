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
for d in `find . \( -name node_modules -or -name .git \) -prune -o -name "$FILE" | grep "$FILE"`
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