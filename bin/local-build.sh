#!/bin/bash

# Install dependencies with Composer
./bin/install-composer-dependencies.sh

# Build assets with gulp
./.circleci/build-gulp-assets.sh