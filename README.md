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
* Local development environment with [Lando](https://docs.devwithlando.io/)
* Asset compilation with [gulp](https://gulpjs.com/) 4
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

## Local Development

### Using Lando as a local development environment
First, take care of the one-time setup steps below:
* Install [Lando](https://docs.devwithlando.io/) if not already installed
* Edit `.lando.yml` and update `name`, `site` and `id` to match those of your Pantheon site
    - You will also need to edit the node proxy if you wish to access BrowserSync at a different URL

Then, use `lando start` and `lando stop` to start and stop the local development environment.

After cloning this repository you will need to download dependencies. This can be done through Lando with the commands below:
* `lando composer-install`
* `lando gulp-build`

Tests can also be run locally on Lando with the commands below:
* `lando composer local-behat`
* `lando composer unit-test`

### Using another local development environment
All of these steps are a one-time step unless noted.

* Install [Composer](https://getcomposer.org) if not already installed
* Install [NodeJS](https://nodejs.org/en/) and [NPM](https://www.npmjs.com/) if not already installed
* Copy `sample.env` to `.env` and update the values accordingly
* Run `./bin/install-composer-dependencies.sh` to install PHP dependencies with Composer
    - `composer update` will need to be ran if `composer.json` has been changed
* Run `./.circleci/build-gulp-assets.sh` to compile theme assets

### Updates and file changes
** Note: ** if you are using Lando for local development prefix all of the commands below with `lando ` to run them on Lando instead of your local system. For example, `npm run dev` would become `lando npm run dev`.

* `composer update` will need to be ran after any changes to `composer.json`
    - Any non-custom PHP code, including to WordPress core, new plugins, etc., should be managed with Composer and updated in this way.
* `npm run gulp` will need to be ran in `web/wp-content/themes/twentyseventeen-child` after any changes to `web/wp-content/themes/twentyseventeen-child/source` files
    - `npm run watch` can be used to build the production CSS and JavaScript files, watch for changes in the source files, and rebuild the production files after a change.
    - `npm run dev` is the same as above but it also starts a [BrowserSync](https://browsersync.io/) instance for automated reloading. Be sure to update the `url` export in `web/wp-content/themes/twentyseventeen-child/gulp/constants.js` with your local development URL. Unless you are using Lando, in which case leave it set to `https://nginx/`.
* `npm install` will need to be ran after any changes to `web/wp-content/themes/twentyseventeen-child/package.json`
    - This is for advanced users who wish to customize their frontend build process.
