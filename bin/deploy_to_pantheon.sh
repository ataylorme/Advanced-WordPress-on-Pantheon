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

# Log into terminus.
echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

# Set variables
COMMIT_MESSAGE="$(git show --name-only --decorate)"
PANTHEON_ENV="dev"
PANTHEON_ENVS="$(terminus multidev:list $PANTHEON_SITE_UUID --format=list --field=Name)"
GITHUB_API_URL="https://api.github.com/repos/$CIRCLE_pull requestOJECT_USERNAME/$CIRCLE_pull requestOJECT_REPONAME"
PANTHEON_SITE_NAME="$(terminus site:info $PANTHEON_SITE_UUID --fields=name --format=string)"
SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_pull requestOJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/code|the dev environment>! \nTo deploy to test run "'`terminus env:deploy '"${PANTHEON_SITE_UUID}"'.test`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#test/deploys|the site dashboard>."

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

git fetch --all

# Check if we are NOT on the master branch and this is a pull request
if [[ $CIRCLE_BRANCH != "master" && -n "$CI_PULL_REQUEST" ]]
then
	# Stash pull request number
	PR_NUMBER=${CI_PULL_REQUEST##*/}
	echo -e "\n${txtylw}Processing pull request #$PR_NUMBER ${txtrst}"


	# Multidev name is the pull request
	PR_BRANCH="pr-$PR_NUMBER"

	# Update the environment variable
	PANTHEON_ENV="${PR_BRANCH}"

	echo -e "\n${txtylw}Checking for the multidev environment ${PR_BRANCH} via Terminus ${txtrst}"

	# Get a list of all environments
	terminus multidev:list $PANTHEON_SITE_UUID --fields=Name

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
		# Send a message
		echo -e "\n${txtylw}Multidev found! ${txtrst}"
	else
		# otherwise, create the multidev branch
		echo -e "\n${txtylw}Multidev not found, creating the multidev branch ${PR_BRANCH} via Terminus ${txtrst}"
		terminus multidev:create $PANTHEON_SITE_UUID.dev $PR_BRANCH

		# put a link to the multidev back on GitHub
		echo -e "\n${txtylw}Linking multidev back to pull request #$PR_NUMBER ${txtrst}"
		MULTDEV_LINK="http://$PR_BRANCH-$PANTHEON_SITE_NAME.pantheonsite.io/"
		curl -i -u "$GIT_USERNAME:$GIT_TOKEN" -d "{\"body\": \"Multidev `$PR_BRANCH` created successfully! [$MULTDEV_LINK]($MULTDEV_LINK)\"}" $GITHUB_API_URL/issues/$PR_NUMBER/comments

		git fetch
	fi

	# Checkout the correct branch
	GIT_BRANCHES="git show-ref --verify refs/heads/$PR_BRANCH"
	if [[ ${GIT_BRANCHES} == *"${PR_BRANCH}"* ]]
	then
		echo -e "\n${txtylw}Branch ${PR_BRANCH} found, checking it out ${txtrst}"
    	git checkout $PR_BRANCH
  	else
  		echo -e "\n${txtylw}Branch ${PR_BRANCH} not found, creating it ${txtrst}"
		git checkout -b $PR_BRANCH
  	fi

	SLACK_MESSAGE="Circle CI build ${CIRCLE_BUILD_NUM} by ${CIRCLE_pull requestOJECT_USERNAME} was successful and has been deployed to Pantheon on <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#${PR_BRANCH}/code|the ${PR_BRANCH} environment>! \nTo merge to dev run "'`terminus multidev:merge-to-dev '"${PANTHEON_SITE_UUID}"'.'"${PR_BRANCH}"'`'" or merge from <https://dashboard.pantheon.io/sites/${PANTHEON_SITE_UUID}#dev/merge|the site dashboard>."
fi

#echo -e "\n${txtylw}Creating a backup of the ${PANTHEON_ENV} environment for site ${PANTHEON_SITE_UUID} ${txtrst}"
#terminus site backups create --element=all --site=$PANTHEON_SITE_UUID --env=$PANTHEON_ENV

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
git commit -m "Circle CI build $CIRCLE_BUILD_NUM by $CIRCLE_pull requestOJECT_USERNAME" -m "$COMMIT_MESSAGE"

# Force push to Pantheon
if [ $CIRCLE_BRANCH != "master" ]
then
	echo -e "\n${txtgrn}Pushing the ${PR_BRANCH} branch to Pantheon ${txtrst}"
	git push -u origin $PR_BRANCH --force
else
	echo -e "\n${txtgrn}Pushing the master branch to Pantheon ${txtrst}"
	git push -u origin master --force
fi

# Cleanup old multidevs
echo -e "\n${txtylw}Cleaning up multidevs from closed pull requests...${txtrst}"
cd $BUILD_DIR
while read -r b; do
	if [[ $b =~ ^pr-[0-9]+ ]]
	then
		PR_NUMBER=${b#pr-}
	else
		echo -e "\n${txtylw}Skipping the multidev: $b since it wasn't made from a pull request...${txtrst}"
		continue
	fi
	echo -e "\n${txtylw}Analyzing the multidev: $b...${txtrst}"
	PR_RESPONSE="$(curl --write-out %{http_code} --silent --output /dev/null $GITHUB_API_URL/pulls/$PR_NUMBER)"
	echo $PR_RESPONSE
	if [ $PR_RESPONSE -eq 200 ]
	then
		PR_STATE="$(curl $GITHUB_API_URL/pulls/$PR_NUMBER | jq -r '.state')"
		if [ "open" == "$PR_STATE"  ]
		then
			echo -e "\n${txtylw}NOT deleting the multidev '$b' since the pull request is still open ${txtrst}"
		else
			echo -e "\n${txtred}Deleting the multidev for closed pull request #$PR_NUMBER...${txtrst}"
			#terminus multidev:delete $PANTHEON_SITE_UUID.$b --delete-branch --yes
		fi
	else
		echo -e "\n${txtred}Invalid pull request number: $PR_NUMBER...${txtrst}"
	fi
done <<< "$PANTHEON_ENVS"
cd -

#Send a message to Slack
echo -e "\n${txtgrn}Sending a message to the ${SLACK_CHANNEL} Slack channel ${txtrst}"
curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_USERNAME}\", \"text\": \"${SLACK_MESSAGE}\"}" $SLACK_HOOK_URL
