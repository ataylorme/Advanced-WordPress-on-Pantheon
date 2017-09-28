#!/bin/bash

set -ex

#==================================================
# The section would be transferable to a DOCKERFILE
#==================================================

# Update current apt packages
apt-get update

# Install node and npm
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

# Install jq
apt-get install -y  jq

# Install gulp globally
npm install --global gulp

#=========================================================================
# Commands below this line would not be transferable to a docker container
#=========================================================================

