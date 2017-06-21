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

		# Stash Circle Artifacts URL
		CIRCLE_ARTIFACTS_URL="https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BUILD_NUM/artifacts/0$CIRCLE_ARTIFACTS"

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
		echo -e "\nRunning backstop reference..."

		backstop reference

		echo -e "\nRunning backstop test..."
		VISUAL_REGRESSION_RESULTS=$(backstop test || echo 'true')

		echo "${VISUAL_REGRESSION_RESULTS}"

		# Rsync files to CIRCLE_ARTIFACTS
		echo -e "\nRsyincing backstop_data files to $CIRCLE_ARTIFACTS..."
		rsync -rlvz backstop_data $CIRCLE_ARTIFACTS

		DIFF_IMAGE=$(find ./backstop_data -type f -name "*.png" | grep diff | head -n 1)
		if [ ! -f $DIFF_IMAGE ]; then
			echo -e "\nDiff image file $DIFF_IMAGE not found!"
			DIFF_IMAGE=$(find ./backstop_data/bitmaps_test -type f -name "*.png" | grep desktop | head -n 1)
		fi
		DIFF_IMAGE_URL="$CIRCLE_ARTIFACTS_URL/$DIFF_IMAGE"
		DIFF_REPORT="$CIRCLE_ARTIFACTS/backstop_data/html_report/index.html"
		if [ ! -f $DIFF_REPORT ]; then
			echo -e "\nDiff report file $DIFF_REPORT not found!"
			exit 1
		fi
		DIFF_REPORT_URL="$CIRCLE_ARTIFACTS_URL/backstop_data/html_report/index.html"

		if [[ "$DIFF_IMAGE" -eq 0 ]]
		then
			REPORT_LINK="[Visual report]($DIFF_REPORT_URL)"
		else
			REPORT_LINK="[![Visual report]($DIFF_IMAGE_URL)]($DIFF_REPORT_URL)"
		fi

		if [[ ${VISUAL_REGRESSION_RESULTS} == *"Mismatch errors found"* ]]
		then
			# visual regression failed
			echo -e "\nVisual regression test failed!"
			PR_MESSAGE="Visual regression test failed! $REPORT_LINK"
		else
			# visual regression passed
			echo -e "\nVisual regression test passed!"
			PR_MESSAGE="Visual regression test passed! $REPORT_LINK"
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
