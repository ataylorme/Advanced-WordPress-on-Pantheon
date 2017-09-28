#!/bin/bash

set -ex

#==================================================
# The section would be transferable to a DOCKERFILE
#==================================================

# Update current apt packages
apt-get update

# Install wget
apt-get install wget -y

# Install node and npm
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

# Install jq
apt-get install -y  jq

# Install Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - 
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update 
apt-get install -y google-chrome-stable

# Install gulp globally
npm install --global gulp

# Install backstop globally
npm install --global backstopjs@3.0.19

#=========================================================================
# Commands below this line would not be transferable to a docker container
#=========================================================================

