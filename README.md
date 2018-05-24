```
    .+?:
     .+??.
       ??? .
       +???.
  +?????????=.
  .???????????.
  .????????????.

 ########### ########
 ############.#######.
 ####### ####  .......
 ######## #### #######
 #########.####.######
 ######  ...
 #######.??.##########
 #######~+??.#########
 ########.??..
 #########.??.#######.
 #########.+?? ######.
           .+?.
     .????????????.
       +??????????,
        .????++++++.
          ????.
          .???,
           .~??.
             .??
              .?,.
```
---
# Advanced WordPress on Pantheon

## Purpose
This repository is an extension of [pantheon-systems/example-wordpress-composer](https://github.com/pantheon-systems/example-wordpress-composer/) 
showning an example of an advanced WordPress 
deployment workflow on Pantheon integrating tools such as:
* Asset compilation with gulp 4
* PHP dependency management with [Composer](https://getcomposer.org/)
* Build and testing processes run on [CircleCI 2.0](https://circleci.com/)
* Unit tests with [PHP Unit](https://phpunit.de/)
* [Behat](http://behat.org/en/latest/) testing with [WordHat](https://github.com/paulgibbs/behat-wordpress-extension/)
* Enforced [WordPress coding standards](https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards) with [PHP code sniffer](https://github.com/squizlabs/PHP_CodeSniffer)
* Performance testing with [Lighthouse](https://developers.google.com/web/tools/lighthouse/)
* Visual regression testing with [BackstopJS](https://github.com/garris/BackstopJS/)

## Deprecated Branch
The old version of this example used CircleCI 1.0 and did a lot of steps that the [Terminus build tools plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin/) now does manually. This has been deprecated in favor of an example based on CircleCI 2.0 and [Example WordPress Composer](https://github.com/pantheon-systems/example-wordpress-composer/). The [circle-ci-1](https://github.com/ataylorme/Advanced-WordPress-on-Pantheon/tree/circle-ci-1) branch has this version archived for reference only.

## CircleCI Setup
You will need to add the following environment variables in the CircleCI UI. See [https://circleci.com/docs/2.0/environment-variables](https://circleci.com/docs/2.0/environment-variables/)/ for details.

* `TERMINUS_SITE`:  Name of the Pantheon site to run tests on, e.g. my_site
* `TERMINUS_TOKEN`: The Pantheon machine token
* `GITHUB_TOKEN`:   The GitHub personal access token
* `GIT_EMAIL`:      The email address to use when making commits
* `TEST_SITE_NAME`: The name of the test site to provide when installing.
* `ADMIN_PASSWORD`: The admin password to use when installing.
* `ADMIN_EMAIL`:    The email address to give the admin when installing.

## Local Setup
In order to develop the site locally a few steps need to be completed. 
These steps only need to be performed once, unless noted. 

* Open a terminal
* Checkout the Git repository
* Enter the Git docroot
* Install Composer if not already installed
* Copy `sample.env` to `.env` and update the values accordingly
* Install Node JS, NPM and Yarn if not already installed
* Run `./bin/local-build.sh` to install Composer dependencies and compile assets with gulp

## Notes
* `npm install` will need to be ran after any changes to `web/wp-content/themes/twentyseventeen-child/package.json` 
* `composer update` will need to be ran after any changes to `composer.json`
* `gulp` will need to be ran in `web/wp-content/themes/twentyseventeen-child` after any changes to `web/wp-content/themes/twentyseventeen-child/source` files
