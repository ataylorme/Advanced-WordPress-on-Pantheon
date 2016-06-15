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
This repository is an example of an advanced WordPress 
deployment workflow on Pantheon integrating tools such as:
* Asset compilation with gulp
* Dependency management with Composer
* Build process on Circle CI

## TODO List
These items are outstanding:
* Example visual regression test
* Example unit test
* Add example for using Grunt instead of gulp to bin/build.sh
* Add example of using a git host besides Github for the source repository
* Add a Slack notification when Circle builds complete, linking to the Pantheon site dashboard

## Warning!
This repository uses an alternate docroot on Pantheon. This feature is pre-release and considered experimental. Do NOT use in production.
If you would like to follow the public progress of the alternate docroot feature see [issue 1651 of the Pantheon documentation repository](https://github.com/pantheon-systems/documentation/issues/1651).

## Circle CI Setup
The following sensitive variables will need to be 
stored in Circle CI as environment variables
* PANTHEON_SITE_UUID
    * The Pantheon UUID of the site to deploy to
* PANTHEON_GIT_URL
    * The SSH URL of the Pantheon Git repository for the above site
* PANTHEON_MACHINE_TOKEN
    * A Pantheon machine token for a user with access to the above repository
* GIT_EMAIL
    * Email address of the account used to make Git commits to the Pantheon repository
* GIT_USERNAME
    * Username of the account used to make Git commits to the Pantheon repository
* GIT_TOKEN
    * A Github token with read access to the source repository
* SLACK_CHANNEL
	* The name of the Slack channel to post messages to
* SLACK_USERNAME
	* The username to post Slack messages with
* SLACK_HOOK_URL
	* The Slack hook URL in the format of `https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX`

## Local Setup
In order to develop the site locally a few steps need to be completed. 
These steps only need to be performed once, unless noted. 

* Open a terminal
* Checkout the Git repository and enter it's directory
* Enter the Git docroot
* Install Composer if not already installed
* Run `composer update`
    * `composer update` will need to be ran after any changes to `composer.json`
* Copy `sample.env` to `.env` and update the values accordingly
* Install Node JS and NPM if not already installed
* Open a new terminal window
* Run `npm install` from the `web/wp-content/themes/twentysixteen-child` directory
    * `npm install` will need to be ran after any changes to `web/wp-content/themes/twentysixteen-child/package.json` 

### Local Development
The gulp _watch_ task initates a BrowserSync session and watches for:
* Changes to `web/wp-content/themes/twentysixteen-child/source/css/twentysixteen-child.scss`, recompiling the CSS build files and injecting changes into the browser
* Changes to `web/wp-content/themes/twentysixteen-child/source/js/twentysixteen-child.js`, recompiling the JavaScript build files and reloading the browser
* Changes to `.php` files in the `web/wp-content/themes/twentysixteen-child` directory, reloading the browser

To start the watch task run `gulp watch` from the `web/wp-content/themes/twentysixteen-child` directory.
When you are done developing stop the task with `ctrl + c`.
