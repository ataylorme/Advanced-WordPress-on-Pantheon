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
    if [ -f 'package.json' ]
    then

        echo -e "\npackage.json found in ${d%/*}"

        #NODE_SASS_INSTALLED=$(npm list | grep node-sass >/dev/null)
        #if [ -z $NODE_SASS_INSTALLED ]
        #then
            # this is necessary as I run MacOS locally but Linux for automated builds
        #    echo -e "\nnode-sass found, rebuilding it's binary..."
        #    npm rebuild node-sass --force >/dev/null 2>&1
        #fi

        echo -e "\nRunning 'npm install'"
        npm install
    fi

	# Run gulp
	echo -e "\nRunning 'gulp'"
	$FOUND

	# Change back again
	echo -e "\nchanged directories back into:"
	cd -
done

exit 0
