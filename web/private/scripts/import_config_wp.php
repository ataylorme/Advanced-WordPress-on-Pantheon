<?php
// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

// Provide the Slack Details
$slack_channel_name = '#advanced-wordpress';
$slack_user_name    = 'WP-CLI-on-Pantheon';
$slack_user_icon    = 'http://live-pantheon-wp-best-practices.pantheonsite.io/wp-content/uploads/icons/wp-cfm.png';

// Activate the wp-cfm plugin
exec( 'wp plugin activate wp-cfm 2>&1' );

// Automagically import config into WP-CFM site upon code deployment

$config_map  = array(
	'test'    => 'pantheon_live',
	'test'    => 'pantheon_test',
	'dev'     => 'pantheon_dev',
	'default' => 'pantheon_dev'
);
$config_name = array_key_exists( PANTHEON_ENVIRONMENT, $config_map ) ? $config_map[ PANTHEON_ENVIRONMENT ] : $config_map['default'];

_slack_tell( 'Importation of WordPress WP-CFM Default Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is starting...', $slack_channel_name, $slack_user_name, $slack_user_icon );

exec( 'wp config pull ' . $config_name . ' 2>&1', $output );
if ( count( $output ) > 0 ) {
	$output = preg_replace( '/\s+/', ' ', array_slice( $output, 1, - 1 ) );
	$output = str_replace( ' update', ' [update]', $output );
	$output = str_replace( ' create', ' [create]', $output );
	$output = str_replace( ' delete', ' [delete]', $output );
	$output = implode( $output, "\n" );
	$output = rtrim( $output );
	_slack_tell( $output, $slack_channel_name, $slack_user_name, $slack_user_icon, '#A9A9A9' );
}

_slack_tell( 'Importation of WordPress WP-CFM Default Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is complete.', $slack_channel_name, $slack_user_name, $slack_user_icon );

$path  = $_SERVER['DOCUMENT_ROOT'] . '/private/config';
$files = scandir( $path );
$files = array_diff( scandir( $path ), array( '.', '..' ) );

foreach( $files as $file ){
	$file_parts = pathinfo($file);

	if( $file_parts['extension'] != 'json' || stripos( $config_map, $file ) !== FALSE ){
		continue;
	}

	_slack_tell( 'Importation of WordPress WP-CFM Default Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is starting...', $slack_channel_name, $slack_user_name, $slack_user_icon );

	exec( 'wp config pull ' . $config_name . ' 2>&1', $output );
	if ( count( $output ) > 0 ) {
		$output = preg_replace( '/\s+/', ' ', array_slice( $output, 1, - 1 ) );
		$output = str_replace( ' update', ' [update]', $output );
		$output = str_replace( ' create', ' [create]', $output );
		$output = str_replace( ' delete', ' [delete]', $output );
		$output = implode( $output, "\n" );
		$output = rtrim( $output );
		_slack_tell( $output, $slack_channel_name, $slack_user_name, $slack_user_icon, '#A9A9A9' );
	}

	_slack_tell( 'Importation of WordPress WP-CFM Default Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is complete.', $slack_channel_name, $slack_user_name, $slack_user_icon );
}

exec( 'wp cache flush' );

print( "\n==== Config Import Complete ====\n" );