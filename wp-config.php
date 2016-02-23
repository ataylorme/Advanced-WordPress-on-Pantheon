<?php
/**
 * Set root path
 */
$rootPath = realpath( __DIR__ . '/..' );

/**
 * Include the Composer autoload
 */
require_once( $rootPath . '/vendor/autoload.php' );

/**
 * Set URL
 */
$server_url = rtrim( $_SERVER['HTTP_HOST'], '/\\' ) . '/';

/**
 * Set custom paths.
 * These are required because WordPress
 * is installed in a subdirectory
 */
define( 'WP_CONTENT_URL', $server_url . 'wp-content' );
define( 'WP_SITEURL', $server_url . 'wp' );
define( 'WP_HOME', $server_url );
define( 'WP_CONTENT_DIR', __DIR__ . '/wp-content' );

/**
 * Disallow on server file edits
 */
define( 'DISALLOW_FILE_EDIT', true );
define( 'DISALLOW_FILE_MODS', true );