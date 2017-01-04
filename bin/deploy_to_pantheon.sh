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

COMMIT_MESSAGE="$(git show --name-only --decorate)"
PANTHEON_ENV="dev"
SITE_ENV="$PANTHEON_SITE_UUID.dev"

cd $HOME

# If the Pantheon directory does not exist
if [ ! -d "$HOME/pantheon" ]
then
	# Clone the Pantheon repo
	echo -e "\n${txtylw}Cloning Pantheon repository into $HOME/pantheon  ${txtrst}"
	git clone $PANTHEON_GIT_URL pantheon
fi

cd pantheon

# If the orphaned wp-content exists
if [ -d "$HOME/pantheon/wp-content" ]
then
	# Remove it
	echo -e "\n${txtylw}Removing $HOME/pantheon/wp-content ${txtrst}"
	rm -rf $HOME/pantheon/wp-content
fi

git fetch

# Log into terminus.
echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_PROJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/code|the dev environment>! \nTo deploy to test run "'`terminus env:deploy test --site='"${SITE_ENV}"'`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/merge|the site dashboard>."

# Check if we are NOT on the master branch
if [ $CIRCLE_BRANCH != "master" ]
then

	# Branch name can't be more than 11 characters
	# Normalize branch name to adhere with Multidev requirements
	export normalize_branch="$CIRCLE_BRANCH"
	export valid="^[-0-9a-z]" # allows digits 0-9, lower case a-z, and -
	# If the branch name is invalid
  	if [[ $normalize_branch =~ $valid ]]
  	then
		export normalize_branch="${normalize_branch:0:11}"
		# Attempt to normalize it
		export normalize_branch="${normalize_branch//[-_]}"
		echo "Success: "$normalize_branch" is a valid branch name."
  	else
  		# Otherwise exit
		echo "Error: Multidev cannot be created due to invalid branch name: $normalize_branch"
		exit 1
	fi

	# Update the environment variable
	PANTHEON_ENV="${normalize_branch}"

	echo -e "\n${txtylw}Checking for the multidev environment ${normalize_branch} via Terminus ${txtrst}"

	# Get a list of all environments
	PANTHEON_ENVS="$(terminus multidev:list --site=$SITE_ENV --format=bash)"
	terminus multidev:list --site=$SITE_ENV

	# If the multidev for this branch is found
	if [[ ${PANTHEON_ENVS} == *"${normalize_branch}"* ]]
	then
		# Send a message
		echo -e "\n${txtylw}Multidev found! ${txtrst}"
	else
		# otherwise, create the multidev branch
		echo -e "\n${txtylw}Multidev not found, creating the multidev branch ${normalize_branch} via Terminus ${txtrst}"
		terminus multidev:create --site=$SITE_ENV dev $normalize_branch
		git fetch
	fi

	# Checkout the correct branch
	GIT_BRANCHES="git show-ref --verify refs/heads/$normalize_branch"
	if [[ ${GIT_BRANCHES} == *"${normalize_branch}"* ]]
	then
		echo -e "\n${txtylw}Branch ${normalize_branch} found, checking it out ${txtrst}"
    	git checkout $normalize_branch
  	else
  		echo -e "\n${txtylw}Branch ${normalize_branch} not found, creating it ${txtrst}"
		git checkout -b $normalize_branch
  	fi

	SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_PROJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#${normalize_branch}/code|the ${normalize_branch} environment>! \nTo merge to dev run "'`terminus multidev:merge-to-dev '"${normalize_branch} --site=${SITE_ENV}"'`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/merge|the site dashboard>."
fi

#echo -e "\n${txtylw}Creating a backup of the ${PANTHEON_ENV} environment for site ${PANTHEON_SITE_UUID} ${txtrst}"
#terminus site backups create --element=all --site=$SITE_ENV --env=$PANTHEON_ENV

# Delete the web and vendor subdirectories if they exist
if [ -d "$HOME/pantheon/web" ]
then
	# Remove it
	echo -e "\n${txtylw}Removing $HOME/pantheon/web ${txtrst}"
	rm -rf $HOME/pantheon/web
fi
if [ -d "$HOME/pantheon/vendor" ]
then
	# Remove it
	echo -e "\n${txtylw}Removing $HOME/pantheon/vendor ${txtrst}"
	rm -rf $HOME/pantheon/vendor
fi

mkdir -p web
mkdir -p vendor

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/web ${txtrst}"
rsync -a $BUILD_DIR/web/* ./web/

echo -e "\n${txtylw}Copying $BUILD_DIR/pantheon.yml ${txtrst}"
cp $BUILD_DIR/pantheon.yml .


echo -e "\n${txtylw}Copying $BUILD_DIR/wp-cli.yml ${txtrst}"
cp $BUILD_DIR/wp-cli.yml .

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/vendor ${txtrst}"
rsync -a $BUILD_DIR/vendor/* ./vendor/

# Some plugins have .svn directories, nuke 'em
echo -e "\n${txtylw}Removing all '.svn' directories${txtrst}"
find . -name '.svn' -type d -exec rm -rf {} \;

# Remove node_modules from gulp/grunt
echo -e "\n${txtylw}Removing all 'node_modules' directories${txtrst}"
find . -name 'node_modules' -type d -exec rm -rf {} \;

# Remove wp-content/uploads if it exists
# Checking in Pantheon's files symlink is bad new
if [ -d "$HOME/pantheon/web/wp-content/uploads" ]
then
	echo -e "\n${txtylw}Removing 'web/wp-content/uploads' symlink${txtrst}"
	rm web/wp-content/uploads
fi

echo -e "\n${txtylw}Forcibly adding all files and committing${txtrst}"
git add -A --force .
git commit -m "Circle CI build $CIRCLE_BUILD_NUM by $CIRCLE_PROJECT_USERNAME" -m "$COMMIT_MESSAGE"

# Force push to Pantheon
if [ $CIRCLE_BRANCH != "master" ]
then
	echo -e "\n${txtgrn}Pushing the ${normalize_branch} branch to Pantheon ${txtrst}"
	git push -u origin $normalize_branch --force
else
	echo -e "\n${txtgrn}Pushing the master branch to Pantheon ${txtrst}"
	git push -u origin master --force
fi

#Send a message to Slack
echo -e "\n${txtgrn}Sending a message to the ${SLACK_CHANNEL} Slack channel ${txtrst}"
curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_USERNAME}\", \"text\": \"${SLACK_MESSAGE}\"}" $SLACK_HOOK_URL
