#!/bin/bash

# Create the WordPress admin user
wp user delete admin --yes
wp user create admin no-reply@pantheon.io --user_pass=admin --role=administrator

# Disable the lh-hsts plugin as it causes a redirect loop
wp plugin deactivate lh-hsts

#Run WordHat
./vendor/bin/behat --config=tests/behat/behat-lando.yml --strict

# Re-enable the lh-hsts plugin
wp plugin deactivate lh-hsts

# Remove the admin user
wp user delete admin --yes