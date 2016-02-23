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
deployment workflow on Pantheon integrating tool such as:
* Asset compilation with gulp
* Dependency management with Composer
* Build process on Circle CI

## TODO List
These items are outstanding:
* Example visual regression test
* Example unit test
* Add example for using Grunt instead of gulp to bin/build.sh
* Add example of using a host besides Github for the source repository

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

## Local Setup
In order to develop the site locally a few steps need to be completed. 
These steps only need to be performed once, unless noted. 

* Open a terminal
* Checkout the Git repository and enter it's directory
* Enter the Git docroot
* Install Composer if not already installed
* Run `composer update`
    * `composer update` will need to be ran after any changes to `composer.json`
* Copy `sample.env` to `.env` and update the value accordingly
* Install Node JS and NPM if not already installed
* Open a new terminal window
* Run `npm install` from the `public/wp-content/themes/twentysixteen-child` directory
    * `npm install` will need to be ran after any changes to `public/wp-content/themes/twentysixteen-child/package.json` 

### Local Development
The gulp _watch_ task initates a BrowserSync session and watches for:
* Changes to `public/wp-content/themes/twentysixteen-child/source/css/twentysixteen-child.scss`, recompiling the CSS build files and injecting changes into the browser
* Changes to `public/wp-content/themes/twentysixteen-child/source/js/twentysixteen-child.js`, recompiling the JavaScript build files and reloading the browser
* Changes to and `.php` files in the `public/wp-content/themes/twentysixteen-child` directory, reloading the browser

To start the watch task run `gulp watch` from the `public/wp-content/themes/twentysixteen-child` directory.
When you are done developing stop the task with `ctrl + c`.