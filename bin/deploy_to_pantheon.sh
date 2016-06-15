#!/bin/bash

# Variables
BUILD_DIR=$(pwd)
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.

# Install Terminus
echo -e "\n${txtylw}Installing Terminus ${txtrst}"
sudo curl https://github.com/pantheon-systems/cli/releases/download/0.11.2/terminus.phar -L -o /usr/local/bin/terminus
sudo chmod +x /usr/local/bin/terminus

COMMIT_MESSAGE="$(git show --name-only --decorate)"
PANTHEON_ENV="dev"

cd $HOME
echo -e "\n${txtylw}Cloning Pantheon repository into $HOME/pantheon  ${txtrst}"
git clone $PANTHEON_GIT_URL pantheon

cd pantheon

# Log into terminus.
echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
terminus auth login --machine-token=$PANTHEON_MACHINE_TOKEN

SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_PROJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#${PANTHEON_ENV}/code|the ${PANTHEON_ENV} environment>! \nTo merge to dev run "'`terminus site merge-to-dev --site='"${PANTHEON_SITE_UUID} --env=${PANTHEON_ENV}"'`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/merge|the site dashboard>."

# Check if we are NOT on the master branch
if [ $CIRCLE_BRANCH != "master" ]
then

	# Branch name can't be more than 11 characters
	BRANCH_LENGTH=${#CIRCLE_BRANCH}
	if (( $BRANCH_LENGTH > 11 ))
	then
		echo -e "\n${txtred}Error: The branch name ${CIRCLE_BRANCH} is longer than 11 characters. ${txtrst}"
		echo -e "\n${txtylw}Pantheon multidev environments require a branch name of 11 characters or less. Please update your branch name and try again. ${txtrst}"
	fi

	# Checkout the correct branch
	if [ `git branch --list $CIRCLE_BRANCH` ]
	then
	   git checkout $CIRCLE_BRANCH
	else
		git checkout -b $CIRCLE_BRANCH
	fi

	# Update the environment variable
	PANTHEON_ENV="${CIRCLE_BRANCH}"

	echo -e "\n${txtylw}Checking for the multidev branch ${CIRCLE_BRANCH} via Terminus ${txtrst}"

	# Get a list of all environments
	PANTHEON_ENVS="$(terminus site environments --site=$PANTHEON_SITE_UUID --format=bash)"
	terminus site environments --site=$PANTHEON_SITE_UUID

	# If the multidev for this branch is found
	if [[ ${PANTHEON_ENVS} == *"${CIRCLE_BRANCH}"* ]]
	then
		echo -e "\n${txtylw}Multidev found! ${txtrst}"
	else
		# otherwise, create it
		echo -e "\n${txtylw}Multidev not found, creating the multidev branch ${CIRCLE_BRANCH} via Terminus ${txtrst}"
		echo -e "Running terminus site create-env --site=$PANTHEON_SITE_UUID --to-env=$CIRCLE_BRANCH --from-env=dev"
		terminus site create-env --site=$PANTHEON_SITE_UUID --to-env=$CIRCLE_BRANCH --from-env=dev

	fi

	SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_PROJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#${PANTHEON_ENV}/code|the ${PANTHEON_ENV} environment>! \nTo merge to dev run "'`terminus site merge-to-dev '"--site=${PANTHEON_SITE_UUID} --env=${PANTHEON_ENV}"'`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/merge|the site dashboard>."
fi

echo -e "\n${txtylw}Creating a backup of the ${PANTHEON_ENV} environment for site ${PANTHEON_SITE_UUID} ${txtrst}"
terminus site backups create --element=all --site=$PANTHEON_SITE_UUID --env=$PANTHEON_ENV

mkdir -p web
mkdir -p vendor

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/web ${txtrst}"
rsync -a $BUILD_DIR/web/* ./web/

echo -e "\n${txtylw}Copying object-cache.php from Redis plugin to wp-content ${txtrst}"
cp web/wp-content/plugins/wp-redis/object-cache.php web/wp-content/object-cache.php

echo -e "\n${txtylw}Copying $BUILD_DIR/pantheon.yml ${txtrst}"
cp $BUILD_DIR/pantheon.yml .

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/vendor ${txtrst}"
rsync -a $BUILD_DIR/vendor/* ./vendor/

echo -e "\n${txtylw}Removing all '.svn' directories${txtrst}"
find . -name '.svn' -type d -exec rm -rf {} \;

echo -e "\n${txtylw}Removing all 'node_modules' directories${txtrst}"
find . -name 'node_modules' -type d -exec rm -rf {} \;

echo -e "\n${txtylw}Forcibly adding all files and committing${txtrst}"
git add -A --force .
git commit -m "Circle CI build $CIRCLE_BUILD_NUM by $CIRCLE_PROJECT_USERNAME" -m "$COMMIT_MESSAGE"

echo -e "\n${txtgrn}Pushing the ${CIRCLE_BRANCH} branch to Pantheon ${txtrst}"
git push -u origin $CIRCLE_BRANCH --force

#Send a message to Slack
echo -e "\n${txtgrn}Sending a message to the ${SLACK_CHANNEL} Slack channel ${txtrst}"
curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_USERNAME}\", \"text\": \"${SLACK_MESSAGE}\"}" $SLACK_HOOK_URL