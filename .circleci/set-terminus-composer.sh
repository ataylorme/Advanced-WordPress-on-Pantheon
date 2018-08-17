#!/bin/bash

set -ex

#=========================================================================
# Commands below this line would not be transferable to a docker container
#=========================================================================

if [ -n "$GITHUB_TOKEN" ] ; then
  composer config --global github-oauth.github.com $GITHUB_TOKEN
fi

# Bail on errors
set +ex

# Make sure Terminus is installed
terminus --version

# Authenticate with Terminus
terminus auth:login -n --machine-token="$TERMINUS_TOKEN" >/dev/null
