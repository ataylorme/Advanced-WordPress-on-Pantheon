#!/bin/bash

# Install dependencies with Composer
./bin/install-composer-dependencies.sh

# Test WordPress coding standards
./bin/test-wordpress-coding-standards.sh

# Compile assets with gulp
if [ -z "${RUN_BEHAT_BUILD}" ]; then
	./bin/build-gulp-assets.sh
fi