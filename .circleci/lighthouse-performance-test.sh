#!/bin/bash

# Variables
BUILD_DIR=$(pwd)
GITHUB_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"

# Check if we are NOT on the master branch and this is a PR
if [[ ${CIRCLE_BRANCH} == "master" || -z ${CIRCLE_PULL_REQUEST+x} ]];
then
	echo -e "\Lighthouse performance test will only run if we are not on the master branch and are making a pull request"
	exit 0
fi

# Stash PR number
PR_NUMBER=${CI_PULL_REQUEST##*/}
echo -e "\nProcessing pull request #$PR_NUMBER"

# Stash site URLs
MULTIDEV_SITE_URL="https://$TERMINUS_ENV-$TERMINUS_SITE.pantheonsite.io/"
LIVE_SITE_URL="https://live-$TERMINUS_SITE.pantheonsite.io/"

# Make artifacts directory
CIRCLE_ARTIFACTS='artifacts'
CIRCLE_ARTIFACTS_DIR='/tmp/artifacts'
mkdir -p $CIRCLE_ARTIFACTS_DIR

# Set Lighthouse results directory, branch and url based on current Git branch
if [[ ${CIRCLE_BRANCH} == "master" ]]; then
	LIGHTHOUSE_BRANCH="master"
	LIGHTHOUSE_URL=$LIVE_SITE_URL
else	
	LIGHTHOUSE_BRANCH=$TERMINUS_ENV
	LIGHTHOUSE_URL=$MULTIDEV_SITE_URL
fi

LIGHTHOUSE_RESULTS_DIR="lighthouse_results/$LIGHTHOUSE_BRANCH"
LIGHTHOUSE_REPORT_NAME="$LIGHTHOUSE_RESULTS_DIR/lighthouse.json"
LIGHTHOUSE_JSON_REPORT="$LIGHTHOUSE_RESULTS_DIR/lighthouse.report.json"
LIGHTHOUSE_HTML_REPORT="$LIGHTHOUSE_RESULTS_DIR/lighthouse.report.html"

# Delete and recreate the Lighthouse results directory so we don't keep old results around
if [ -d "$LIGHTHOUSE_RESULTS_DIR" ]; then
  rm -rf $LIGHTHOUSE_RESULTS_DIR
  mkdir $LIGHTHOUSE_RESULTS_DIR
fi

# Stash Circle Artifacts URL
CIRCLE_ARTIFACTS_URL="$CIRCLE_BUILD_URL/artifacts/$CIRCLE_NODE_INDEX/$CIRCLE_ARTIFACTS"

# Ping the Pantheon environment to wake it from sleep and prime the cache
echo -e "\nPinging the ${LIGHTHOUSE_BRANCH} environment to wake it from sleep..."
curl -I "$LIGHTHOUSE_URL" >/dev/null

# Run the Lighthouse test
echo -e "\nRunning lighthouse --perf --save-artifacts --output json --output html --output-path ${LIGHTHOUSE_REPORT_NAME} --chrome-flags=\"--headless\" ${LIGHTHOUSE_URL}..."

lighthouse --perf --save-artifacts --output json --output html --output-path ${LIGHTHOUSE_REPORT_NAME} --chrome-flags="--headless" ${LIGHTHOUSE_URL}

# Rsync files to CIRCLE_ARTIFACTS_DIR
echo -e "\nRsyincing lighthouse_results files to $CIRCLE_ARTIFACTS_DIR..."
rsync -rlvz lighthouse_results $CIRCLE_ARTIFACTS_DIR

# Check for HTML report file
if [ ! -f $LIGHTHOUSE_HTML_REPORT ]; then
	echo -e "\nLighthouse HTML report file $LIGHTHOUSE_HTML_REPORT not found!"
	exit 1
fi

# Check for JSON report file
if [ ! -f $LIGHTHOUSE_JSON_REPORT ]; then
	echo -e "\nLighthouse JSON report file $LIGHTHOUSE_JSON_REPORT not found!"
	exit 1
fi

LIGHTHOUSE_HTML_REPORT_URL="$CIRCLE_ARTIFACTS_URL/$LIGHTHOUSE_HTML_REPORT"
REPORT_LINK="[Lighthouse report]($LIGHTHOUSE_HTML_REPORT_URL)"

#if [[ ${VISUAL_REGRESSION_RESULTS} == *"Mismatch errors found"* ]]
#then
#	# visual regression failed
#	echo -e "\nVisual regression test failed!"
#	PR_MESSAGE="Visual regression test failed! $REPORT_LINK"
#else
#	# visual regression passed
#	REPORT_LINK="\n[Visual report]($DIFF_REPORT_URL)"
#	echo -e "\nVisual regression test passed!"
#	PR_MESSAGE="Visual regression test passed! $REPORT_LINK"
#fi

# Post the report back to the pull request on GitHub
echo -e "\nPosting Lighthouse results back to $LIGHTHOUSE_BRANCH "
curl -i -u "$GIT_USERNAME:$GIT_TOKEN" -d "{\"body\": \"$REPORT_LINK\"}" $GITHUB_API_URL/issues/$PR_NUMBER/comments
