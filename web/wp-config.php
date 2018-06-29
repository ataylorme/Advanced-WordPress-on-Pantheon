<?php
/**
 * Advanced WordPress on Pantheon wp-config.php
 *
 * @package AdvancedWordPressOnPantheon
 */

/**
 * Don't show deprecations
 */
// @codingStandardsIgnoreStart
error_reporting( E_ALL ^ E_DEPRECATED );
// @codingStandardsIgnoreEnd

/**
 * Set root path
 */
$root_path = realpath( __DIR__ . '/..' );

/**
 * Include the Composer autoload
 */
require_once( $root_path . '/vendor/autoload.php' );

/**
 * Fetch .env
 */
if ( ! isset( $_ENV['PANTHEON_ENVIRONMENT'] ) && file_exists( $root_path . '/.env' ) ) {
	$dotenv = new Dotenv\Dotenv( $root_path );
	$dotenv->load();
	$dotenv->required( array(
		'DB_NAME',
		'DB_USER',
		'DB_HOST',
		'AUTH_KEY',
		'SECURE_AUTH_KEY',
		'LOGGED_IN_KEY',
		'NONCE_KEY',
		'AUTH_SALT',
		'SECURE_AUTH_SALT',
		'LOGGED_IN_SALT',
		'NONCE_SALT',
	) )->notEmpty();
}

/**
 * Are we working locally?
 * Yes if there is a .env file
 * or we are using Lando
 */
if ( 
    getenv( 'IS_LOCAL' ) !== false || 
        (
            isset( $_ENV['PANTHEON_ENVIRONMENT'] ) && 
            'lando' === $_ENV['PANTHEON_ENVIRONMENT'] 
        ) 
    ) {
    define( 'IS_LOCAL', true );
} else {
    define( 'IS_LOCAL', false );
}

/**
 * Disallow on server file edits unless working locally
 * or on the Pantheon dev environment
 */
if ( ! IS_LOCAL && ( isset( $_ENV['PANTHEON_ENVIRONMENT'] ) &&  in_array( $_ENV['PANTHEON_ENVIRONMENT'], array( 'test', 'live' ), true ) ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
	define( 'DISALLOW_FILE_MODS', true );
}

/**
 * Force SSL
 */
define( 'FORCE_SSL_ADMIN', true );

/**
 * Limit post revisions
 */
define( 'WP_POST_REVISIONS', 3 );

/**
 * Set Database Details
 */
define( 'DB_NAME', getenv( 'DB_NAME' ) );
define( 'DB_USER', getenv( 'DB_USER' ) );
define( 'DB_PASSWORD', getenv( 'DB_PASSWORD' ) );
define( 'DB_HOST', getenv( 'DB_HOST' )  . ':' . getenv( 'DB_PORT' ) );
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

/**
 * Set debug modes
 */
define( 'WP_DEBUG', getenv( 'WP_DEBUG' ) == 'true' ? true : false );

/**
 * Define site and home URLs
 */
if ( isset( $_ENV['PANTHEON_ENVIRONMENT'] ) && 'lando' === $_ENV['PANTHEON_ENVIRONMENT'] ) {
    // If on Lando use HTTP_HOST if set
    if ( isset( $_SERVER['HTTP_HOST'] ) ) {
        $site_url = 'https://' . $_SERVER['HTTP_HOST'] . '/';
    } else if( php_sapi_name() == 'cli' ) {
        // Otherwise, if we are in wp-cli use the internal container URL
        $site_url = 'https://nginx/';
    } else {
        // Fall back to the app name if nothing else
        $site_url = 'https://' . $_SERVER['LANDO_APP_NAME'] . '.lndo.site/';
    }
} else {
    // If not on Lando check for WP_HOME in .env, otherwise use HTTP_HOST
    $site_url = getenv( 'WP_HOME' ) !== false ? getenv( 'WP_HOME' ) : 'https://' . $_SERVER['HTTP_HOST'] . '/';
}
define( 'WP_HOME', $site_url );
define( 'WP_SITEURL', $site_url . 'wp/' );

/**
 * Define keys
 */
define( 'AUTH_KEY', getenv( 'AUTH_KEY' ) );
define( 'SECURE_AUTH_KEY', getenv( 'SECURE_AUTH_KEY' ) );
define( 'LOGGED_IN_KEY', getenv( 'LOGGED_IN_KEY' ) );
define( 'NONCE_KEY', getenv( 'NONCE_KEY' ) );
define( 'AUTH_SALT', getenv( 'AUTH_SALT' ) );
define( 'SECURE_AUTH_SALT', getenv( 'SECURE_AUTH_SALT' ) );
define( 'LOGGED_IN_SALT', getenv( 'LOGGED_IN_SALT' ) );
define( 'NONCE_SALT', getenv( 'NONCE_SALT' ) );

/**
 * Check for PANTHEON_BINDING
 */
if ( defined( 'PANTHEON_BINDING' ) ) {
    define( 'WP_TEMP_DIR', sprintf( '/srv/bindings/%s/tmp', PANTHEON_BINDING ) );
}

/**
* Define wp-content directory outside of WordPress core directory
*/
define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/wp-content' );
define( 'WP_CONTENT_URL', WP_HOME . '/wp-content' );

/**
 * Define docroot
 */
if ( ! defined( 'DOCROOT' ) ) {
	define( 'DOCROOT', dirname( __FILE__ ) . '/' );
}

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = getenv( 'DB_PREFIX' ) !== false ? getenv( 'DB_PREFIX' ) : 'wp_';

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}
/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
