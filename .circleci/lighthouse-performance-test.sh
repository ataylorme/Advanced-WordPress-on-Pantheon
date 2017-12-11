#!/bin/bash

# Variables
BUILD_DIR=$(pwd)
GITHUB_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"

# Check if we are NOT on the master branch and this is a PR
if [[ ${CIRCLE_BRANCH} != "master" && -z ${CIRCLE_PULL_REQUEST+x} ]];
then
	echo -e "\Lighthouse performance test will only run if not on the master branch when making a pull request"
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
LIGHTHOUSE_RESULTS_JSON="$LIGHTHOUSE_RESULTS_DIR/lighthouse.results.json"

# Delete the Lighthouse results directory so we don't keep old results around
if [ -d "$LIGHTHOUSE_RESULTS_DIR" ]; then
  rm -rf $LIGHTHOUSE_RESULTS_DIR
fi

# Create the Lighthouse results directory if it doesn't exist or has been deleted
mkdir -p $LIGHTHOUSE_RESULTS_DIR

# Create the Lighthouse results directory for master if needed
if [ ! -d "lighthouse_results/master" ]; then
	mkdir -p "lighthouse_results/master"
fi

# Stash Circle Artifacts URL
CIRCLE_ARTIFACTS_URL="$CIRCLE_BUILD_URL/artifacts/$CIRCLE_NODE_INDEX/$CIRCLE_ARTIFACTS"

# Ping the Pantheon environment to wake it from sleep and prime the cache
echo -e "\nPinging the ${LIGHTHOUSE_BRANCH} environment to wake it from sleep..."
curl -s -I "$LIGHTHOUSE_URL" >/dev/null

# Run the Lighthouse test
lighthouse --perf --save-artifacts --output json --output html --output-path ${LIGHTHOUSE_REPORT_NAME} --chrome-flags="--headless --disable-gpu --no-sandbox" ${LIGHTHOUSE_URL}

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

# Create tailored results JSON file
cat $LIGHTHOUSE_JSON_REPORT | jq '. | { "total-score": .score, "speed-index": .audits["speed-index-metric"]["score"], "first-meaningful-paint": .audits["first-meaningful-paint"]["score"], "estimated-input-latency": .audits["estimated-input-latency"]["score"], "time-to-first-byte": .audits["time-to-first-byte"]["rawValue"], "first-interactive": .audits["first-interactive"]["score"], "consistently-interactive": .audits["consistently-interactive"]["score"], "critical-request-chains": .audits["critical-request-chains"]["displayValue"], "redirects": .audits["redirects"]["score"], "bootup-time": .audits["bootup-time"]["rawValue"], "uses-long-cache-ttl": .audits["uses-long-cache-ttl"]["score"], "total-byte-weight": .audits["total-byte-weight"]["score"], "offscreen-images": .audits["offscreen-images"]["score"], "uses-webp-images": .audits["uses-webp-images"]["score"], "uses-optimized-images": .audits["uses-optimized-images"]["score"], "uses-request-compression": .audits["uses-request-compression"]["score"], "uses-responsive-images": .audits["uses-responsive-images"]["score"], "dom-size": .audits["dom-size"]["score"], "script-blocking-first-paint": .audits["script-blocking-first-paint"]["score"] }' > $LIGHTHOUSE_RESULTS_JSON

LIGHTHOUSE_SCORE=$(cat $LIGHTHOUSE_RESULTS_JSON | jq '.["total-score"] | floor | tonumber')
LIGHTHOUSE_HTML_REPORT_URL="$CIRCLE_ARTIFACTS_URL/$LIGHTHOUSE_HTML_REPORT"

# Rsync files to CIRCLE_ARTIFACTS_DIR
echo -e "\nRsyincing lighthouse_results files to $CIRCLE_ARTIFACTS_DIR..."
rsync -rlvz lighthouse_results $CIRCLE_ARTIFACTS_DIR

# If we are on on the master branch
if [[ ${CIRCLE_BRANCH} == "master" ]]; then
	echo -e "\nLighthouse score is $LIGHTHOUSE_SCORE"
	exit 0
fi

LIGHTHOUSE_MASTER_RESULTS_DIR="lighthouse_results/master"
LIGHTHOUSE_MASTER_REPORT_NAME="$LIGHTHOUSE_MASTER_RESULTS_DIR/lighthouse.json"
LIGHTHOUSE_MASTER_JSON_REPORT="$LIGHTHOUSE_MASTER_RESULTS_DIR/lighthouse.report.json"
LIGHTHOUSE_MASTER_HTML_REPORT="$LIGHTHOUSE_MASTER_RESULTS_DIR/lighthouse.report.html"
LIGHTHOUSE_MASTER_RESULTS_JSON="$LIGHTHOUSE_MASTER_RESULTS_DIR/lighthouse.results.json"

# Ping the live environment to wake it from sleep and prime the cache
echo -e "\nPinging the live environment to wake it from sleep..."
curl -s -I "$LIVE_SITE_URL" >/dev/null

# Run Lighthouse on the live environment
echo -e "\nRunning Lighthouse on the live environment"
lighthouse --perf --save-artifacts --output json --output html --output-path "$LIGHTHOUSE_MASTER_REPORT_NAME" --chrome-flags="--headless --disable-gpu --no-sandbox" ${LIVE_SITE_URL}

# Create tailored results JSON file
cat $LIGHTHOUSE_MASTER_JSON_REPORT | jq '. | { "total-score": .score, "speed-index": .audits["speed-index-metric"]["score"], "first-meaningful-paint": .audits["first-meaningful-paint"]["score"], "estimated-input-latency": .audits["estimated-input-latency"]["score"], "time-to-first-byte": .audits["time-to-first-byte"]["rawValue"], "first-interactive": .audits["first-interactive"]["score"], "consistently-interactive": .audits["consistently-interactive"]["score"], "critical-request-chains": .audits["critical-request-chains"]["displayValue"], "redirects": .audits["redirects"]["score"], "bootup-time": .audits["bootup-time"]["rawValue"], "uses-long-cache-ttl": .audits["uses-long-cache-ttl"]["score"], "total-byte-weight": .audits["total-byte-weight"]["score"], "offscreen-images": .audits["offscreen-images"]["score"], "uses-webp-images": .audits["uses-webp-images"]["score"], "uses-optimized-images": .audits["uses-optimized-images"]["score"], "uses-request-compression": .audits["uses-request-compression"]["score"], "uses-responsive-images": .audits["uses-responsive-images"]["score"], "dom-size": .audits["dom-size"]["score"], "script-blocking-first-paint": .audits["script-blocking-first-paint"]["score"] }' > $LIGHTHOUSE_MASTER_RESULTS_JSON

LIGHTHOUSE_MASTER_SCORE=$(cat $LIGHTHOUSE_MASTER_RESULTS_JSON | jq '.["total-score"] | floor | tonumber')

# Rsync files to CIRCLE_ARTIFACTS_DIR again now that we have master results
echo -e "\nRsyincing lighthouse_results files to $CIRCLE_ARTIFACTS_DIR..."
rsync -rlvz lighthouse_results $CIRCLE_ARTIFACTS_DIR

echo -e "\nMaster score of $LIGHTHOUSE_MASTER_SCORE recorded"

LIGHTHOUSE_MASTER_HTML_REPORT_URL="$CIRCLE_ARTIFACTS_URL/$LIGHTHOUSE_MASTER_HTML_REPORT"
REPORT_LINK="[Lighthouse performance report for \`$CIRCLE_BRANCH\`]($LIGHTHOUSE_HTML_REPORT_URL) and compare it to the [Lighthouse performance report for the \`master\` branch]($LIGHTHOUSE_MASTER_HTML_REPORT_URL)"

# Level of tolerance for score decline	
LIGHTHOUSE_ACCEPTABLE_THRESHOLD=5
LIGHTHOUSE_ACCEPTABLE_SCORE=$((LIGHTHOUSE_MASTER_SCORE-LIGHTHOUSE_ACCEPTABLE_THRESHOLD))
if [ $LIGHTHOUSE_SCORE -lt $LIGHTHOUSE_ACCEPTABLE_SCORE ]; then
	# Lighthouse test failed! The score is less than the acceptable score
	echo -e "\nLighthouse test failed! The score of $LIGHTHOUSE_SCORE is less than the acceptable score of $LIGHTHOUSE_ACCEPTABLE_SCORE ($LIGHTHOUSE_ACCEPTABLE_THRESHOLD less than the score of $LIGHTHOUSE_MASTER_SCORE on the master branch)"
	PR_MESSAGE="Lighthouse test failed! The score of \`$LIGHTHOUSE_SCORE\` is than the acceptable score of \`$LIGHTHOUSE_ACCEPTABLE_SCORE\` (\`$LIGHTHOUSE_ACCEPTABLE_THRESHOLD\` less than the score of \`$LIGHTHOUSE_MASTER_SCORE\` on the master branch)"

	PR_MESSAGE="$PR_MESSAGE\n\nView the full $REPORT_LINK"

	# Post the report back to the pull request on GitHub
	echo -e "\nPosting Lighthouse results back to $LIGHTHOUSE_BRANCH "
	curl -s -i -u "$GIT_USERNAME:$GIT_TOKEN" -d "{\"body\": \"$PR_MESSAGE\"}" $GITHUB_API_URL/issues/$PR_NUMBER/comments

	exit 1
else
	# Lighthouse test passed! The score isn't less than the acceptable score
	echo -e "\nLighthouse test passed! The score of $LIGHTHOUSE_SCORE isn't less than the acceptable score of $LIGHTHOUSE_ACCEPTABLE_SCORE ($LIGHTHOUSE_ACCEPTABLE_THRESHOLD less than the score of $LIGHTHOUSE_MASTER_SCORE on the master branch)"
	PR_MESSAGE="Lighthouse test passed! The score of \`$LIGHTHOUSE_SCORE\` isn't less than the acceptable score of \`$LIGHTHOUSE_ACCEPTABLE_SCORE\` (\`$LIGHTHOUSE_ACCEPTABLE_THRESHOLD\` less than the score of \`$LIGHTHOUSE_MASTER_SCORE\` on the master branch)"

	PR_MESSAGE="$PR_MESSAGE\n\nView the full $REPORT_LINK"

	# Post the report back to the pull request on GitHub
	echo -e "\nPosting Lighthouse results back to $LIGHTHOUSE_BRANCH "
	curl -s -i -u "$GIT_USERNAME:$GIT_TOKEN" -d "{\"body\": \"$PR_MESSAGE\"}" $GITHUB_API_URL/issues/$PR_NUMBER/comments

	exit 0
fi
