#!/bin/bash

# Install code sniffer
composer global require squizlabs/php_codesniffer:2.9.x-dev

# Install WordPress coding standards
composer global require wp-coding-standards/wpcs

# Add WordPress coding standards path to code sniffer
phpcs --config-set installed_paths $HOME/.composer/vendor/wp-coding-standards/wpcs

# Change to project directory
cd $HOME/$CIRCLE_PROJECT_REPONAME

# Sniff all PHP files
phpcs --standard=phpcs.ruleset.xml --config-set ignore_warnings_on_exit 1 $(find . -name '*.php')

# Change directories back to wherever we were before
cd -