<?php
/*
 * Custom wp-config.php settings
 */

/**
 * Set root path
 */
$rootPath = realpath( __DIR__ . '/..' );

/**
 * Include the Composer autoload
 */
require_once( $rootPath . '/vendor/autoload.php' );

/**
 * Disallow on server file edits
 */
define( 'DISALLOW_FILE_EDIT', true );
define( 'DISALLOW_FILE_MODS', true );

/**
 * Begin Pantheon wp-config.php
 *
 *         .+?:
 *          .+??.
 *            ??? .
 *            +???.
 *       +?????????=.
 *       .???????????.
 *       .????????????.
 *
 *      ########### ########
 *      ############.#######.
 *      ####### ####  .......
 *      ######## #### #######
 *      #########.####.######
 *      ######  ...
 *      #######.??.##########
 *      #######~+??.#########
 *      ########.??..
 *      #########.??.#######.
 *      #########.+?? ######.
 *                .+?.
 *          .????????????.
 *            +??????????,
 *             .????++++++.
 *               ????.
 *               .???,
 *                .~??.
 *                  .??
 *                   .?,.
 */

