#!/bin/bash

# Color Variables
BUILD_DIR=$(pwd)
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.

# Variables
BUILD_DIR=$(pwd)
GITHUB_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"

# Authenticate with Terminus
./bin/terminus_auth.sh

# Check if we are NOT on the master branch and this is a PR
if [[ $CIRCLE_BRANCH != "master" && -n "$CI_PULL_REQUEST" ]]
then
		# Log into terminus.
	echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
	terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

	# Stash site name
	PANTHEON_SITE_NAME="$(terminus site:info $PANTHEON_SITE_UUID --fields=name --format=string)"

	# Stash PR number
	PR_NUMBER=${CI_PULL_REQUEST##*/}
	echo -e "\n${txtylw}Processing pull request #$PR_NUMBER ${txtrst}"

	# Multidev name is the pull request
	PR_BRANCH="pr-$PR_NUMBER"

	echo -e "\n${txtylw}Checking for the multidev environment ${PR_BRANCH} via Terminus ${txtrst}"

	# Get a list of all environments
	terminus multidev:list $PANTHEON_SITE_UUID --fields=Name
	PANTHEON_ENVS="$(terminus multidev:list $PANTHEON_SITE_UUID --format=list --field=Name)"

	MULTIDEV_FOUND=0

	while read -r line; do
		if [[ "${line}" == "${PR_BRANCH}" ]]
		then
			MULTIDEV_FOUND=1
		fi
	done <<< "$PANTHEON_ENVS"

	# If the multidev for this branch is found
	if [[ "$MULTIDEV_FOUND" -eq 1 ]]
	then

		# Stash site URLs
		MULTIDEV_SITE_URL="https://$PR_BRANCH-$PANTHEON_SITE_NAME.pantheonsite.io/"
		LIVE_SITE_URL="https://live-$PANTHEON_SITE_NAME.pantheonsite.io/"

		# Install node dependencies
		echo -e "\nRunning npm install..."
		npm install

		# Ping the multidev environment to wake it from sleep
		echo -e "\nPinging the ${PR_BRANCH} multidev environment to wake it from sleep..."
		curl -I "$MULTIDEV_SITE_URL" >/dev/null
		
		# Ping the live environment to wake it from sleep
		echo -e "\nPinging the live environment to wake it from sleep..."
		curl -I "$LIVE_SITE_URL" >/dev/null

		# Create Backstop config file with URLs
		echo -e "\nCreating backstop.js config file..."
		cat backstop.json.default | jq ".scenarios[0].url = \"$LIVE_SITE_URL\" | .scenarios[0].referenceUrl = \"$MULTIDEV_SITE_URL\" " > backstop.json

		# Backstop visual regression
		echo -e "\nRunning BackstopJS tests..."

		cd node_modules/backstopjs

		npm run reference

		VISUAL_REGRESSION_RESULTS=$(npm run test)

		echo "${VISUAL_REGRESSION_RESULTS}"

		cd -

		if [[ ${VISUAL_REGRESSION_RESULTS} == *"Mismatch errors found"* ]]
		then
			# Upload the image to uploads.im
			echo -e "\nUploading the failed diff image to uploads.im..."
			IMAGE_FILE=$(find ./bitmaps_test -type f -name "*.png" | grep failed)
			curl -F "upload=@$IMAGE_FILE" http://uploads.im/api
			UPLOADED_DIFF_IMAGE="$(curl -F \"upload=@$IMAGE_FILE\" http://uploads.im/api | jq -r '.data.img_url')"
			# visual regression failed
			PR_MESSAGE="Visual regression test failed! ![Visual Regression Test Result]($UPLOADED_DIFF_IMAGE)"
		else
			# Upload the image to uploads.im
			echo -e "\nUploading the passed diff image to uploads.im..."
			IMAGE_FILE=$(find ./bitmaps_test -type f -name "*.png" | grep passed)
			curl -F "upload=@$IMAGE_FILE" http://uploads.im/api
			UPLOADED_DIFF_IMAGE="$(curl -F \"upload=@$IMAGE_FILE\" http://uploads.im/api | jq -r '.data.img_url')"
			# visual regression passed
			PR_MESSAGE="Visual regression test passed! ![Visual Regression Test Result]($UPLOADED_DIFF_IMAGE)"
		fi
		
		# Post the image back to the pull request on GitHub
		echo -e "\n${txtylw}Posting visual regression results back to PR #$PR_NUMBER ${txtrst}"
		curl -i -u "$GIT_USERNAME:$GIT_TOKEN" -d "{\"body\": \"$PR_MESSAGE\"}" $GITHUB_API_URL/issues/$PR_NUMBER/comments
	else
		# otherwise, bail if multidev isn't found
		echo -e "\n${txtred}Error: Multidev ${PR_BRANCH} not found, skipping visual regression test ${txtrst}"
		exit 1
	fi
fi
