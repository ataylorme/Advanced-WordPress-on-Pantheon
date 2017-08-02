#!/bin/bash

#
# Build assets with gulp
#

EXE=gulp

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo -e "\nError: executable gulp not found on path"
	exit 1
fi

# Look for gulpfile.js occurrences NOT in node_modules
echo -e "\nLooking for gulpfile.js occurrences NOT in node_modules.."
FILE=gulpfile.*js
for d in `find . \( -name node_modules -or -name .git \) -prune -o -name "$FILE" | grep "$FILE"`
do
	# Change into containing directory
	echo -e "\ngulpfile found, changing directories into: ${d%/*}"
	cd ${d%/*}

	# Install any dependencies, if we find packages.json
	[ -f 'package.json' ] && echo -e "\npackage.json found, running 'npm install'"
	[ -f 'package.json' ] && npm install

	# Run gulp
	echo -e "\nRunning 'gulp'"
	$FOUND

	# Change back again
	echo -e "\nchanged directories back into:"
	cd -
done
