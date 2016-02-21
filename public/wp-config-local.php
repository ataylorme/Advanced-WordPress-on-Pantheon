<?php

/**
 * Set root path
 */
$rootPath = realpath( __DIR__ . '/..' );

/**
 * Include the Composer autoload
 */
require_once( $rootPath . '/vendor/autoload.php' );

/*
 * Fetch .env
 */
if ( file_exists( $rootPath . '/.env' ) ) {
    $dotenv = new Dotenv\Dotenv( $rootPath );
    $dotenv->load();
    $dotenv->required( array(
        'DB_NAME',
        'DB_USER',
        'DB_PASSWORD',
        'DB_HOST',
    ))->notEmpty();
}

/**
 * Set Database Details
 */
define( 'DB_NAME', getenv( 'DB_NAME' ) );
define( 'DB_USER', getenv( 'DB_USER' ) );
define( 'DB_PASSWORD', getenv( 'DB_PASSWORD' ) );
define( 'DB_HOST', getenv( 'DB_HOST' ) );

/**
 * Set debug modes
 */
define( 'WP_DEBUG', getenv( 'WP_DEBUG' ) === 'true' ? true : false );
define( 'IS_LOCAL', getenv( 'IS_LOCAL' ) !== false ? true : false );

define( 'WP_POST_REVISIONS', 3 );

// Disallow on server file edits
define( 'DISALLOW_FILE_EDIT', true );
define( 'DISALLOW_FILE_MODS', true );


/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '^J/U[^{cOJxhcmmCq2MX%nUs}i_^7nm[w+VsetLZ[JXW9Un/IiyWVEXk;s}X=?u$');
define('SECURE_AUTH_KEY',  'dT,wlW20L5V3ChmTEHFGVtUE-r&A)y+G%Pnql&eKdVAWvdIr9FO4lh_Gc9ZVn!1|');
define('LOGGED_IN_KEY',    '{0E{}k_e7!XRt*}h}nuMP[sKn$gb(O@|[>?bUs}B{>:|+|lL%czE/!Tlc Uk53#:');
define('NONCE_KEY',        '|M9$H1t9D@AR6>JM[]?9RoA^dmOCHt6ldAE%x|0 Iqpi+m32>1>?0*_?*#|6f7|W');
define('AUTH_SALT',        'CA-BmAsS|o_P|!I8Wfu%a=qXC;!3p[8]W_:N2{oI]HhpLP(%2]zWLH+aHTHDw9>%');
define('SECURE_AUTH_SALT', 'pi-EA,AOXk*U[VZ|t]R;@K<WMcbD)>k* ;8+hKX:A|$.Z@HL@0`SE?W0:-?-IRd!');
define('LOGGED_IN_SALT',   'e+6%u)u@RZn-$}_Q[N;Na<|A-[Am_$#nhD~}ci:%R&B*oiq<sPF$v)d1r<-V-5W|');
define('NONCE_SALT',       'r%oyx_`[A-~<LB)]I.,^//}/&]a)H|fzk3IUWrZn[L4qf#Pp#lsB-B}+/ai&u,/|');

/**
 * Don't show deprecations
 */
error_reporting( E_ALL ^ E_DEPRECATED );

/**
 * WordPress Localized Language, defaults to English.
 */
define( 'WPLANG', '' );

/**
 * WordPress Database Table prefix
 * Use something other than `wp_` for security
 */
$table_prefix = getenv( 'DB_PREFIX' ) !== false ? getenv( 'DB_PREFIX' ) : 'wp_';

/**
 * Absolute path to the WordPress directory
 */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

require_once( ABSPATH . 'wp-settings.php' );