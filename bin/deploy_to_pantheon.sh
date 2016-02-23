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
sudo curl https://github.com/pantheon-systems/cli/releases/download/0.10.4/terminus.phar -L -o /usr/local/bin/terminus
sudo chmod +x /usr/local/bin/terminus

# Log into terminus.
echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
terminus auth login --machine-token=$PANTHEON_MACHINE_TOKEN

echo -e "\n${txtylw}Creating a backup of the dev environment for site $PANTHEON_SITE_UUID ${txtrst}"
terminus site backups create --element=all --site=$PANTHEON_SITE_UUID --env=dev

COMMIT_MESSAGE="$(git show --name-only --decorate)"

cd $HOME
echo -e "\n${txtylw}Cloning Pantheon repository into $HOME/pantheon  ${txtrst}"
git clone $PANTHEON_GIT_URL pantheon

cd pantheon

mkdir -p public
mkdir -p vendor

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/public ${txtrst}"
rsync -a $BUILD_DIR/public/* ./public/

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

echo -e "\n${txtylw}Pushing to pantheon  ${txtrst}"
git push --force origin master