#!/bin/bash

# Install dependencies with Composer
./bin/install-composer-dependencies.sh

# Build assets with gulp
./.circleci/build-gulp-assets.sh

# Test WordPress coding standards
./vendor/bin/phpcs --config-set installed_paths ./vendor/wp-coding-standards/wpcs
./vendor/bin/phpcs --ignore=*/.git*/*,*/node_modules/* --extensions=php ./web/wp-content/themes/twentyseventeen-child

# Run unit tests
composer -n unit-test
