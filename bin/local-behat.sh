#!/bin/bash

# Create the WordPress admin user
lando wp user delete admin --yes
lando wp user create admin no-reply@pantheon.io --user_pass=admin --role=administrator

# Disable the lh-hsts plugin as it causes a redirect loop
lando wp plugin deactivate lh-hsts

#Run WordHat
lando wordhat

# Re-enable the lh-hsts plugin
lando wp plugin deactivate lh-hsts

# Remove the admin user
lando wp user delete admin --yes