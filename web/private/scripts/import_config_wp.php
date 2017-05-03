<?php
// Secrets helper function
require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

$secrets = _get_secrets( array( 'slack_channel', 'live_url' ) );

// Provide the Slack Details
$slack_channel_name = $secrets['slack_channel'];
$slack_user_name    = 'WP-CLI-on-Pantheon';
$slack_user_icon    = $secrets['live_url'] . '/slack-icons/wp-cfm.png';

// Activate the wp-cfm plugin
exec( 'wp plugin activate wp-cfm 2>&1' );

// Automagically import config into WP-CFM site upon code deployment
$path  = $_SERVER['DOCUMENT_ROOT'] . '/private/config';
$files = scandir( $path );
$files = array_diff( scandir( $path ), array( '.', '..' ) );

foreach( $files as $file ){
	$file_parts = pathinfo($file);

	if( $file_parts['extension'] != 'json' ){
		continue;
	}

	_slack_tell( 'Importation of WordPress WP-CFM ' . $file . ' Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is starting...', $slack_channel_name, $slack_user_name, $slack_user_icon );

	exec( 'wp config pull ' . $file_parts['filename'] . ' 2>&1', $output );
	if ( count( $output ) > 0 ) {
		$output = preg_replace( '/\s+/', ' ', array_slice( $output, 1, - 1 ) );
		$output = str_replace( ' update', ' [update]', $output );
		$output = str_replace( ' create', ' [create]', $output );
		$output = str_replace( ' delete', ' [delete]', $output );
		$output = implode( $output, "\n" );
		$output = rtrim( $output );
		_slack_tell( $output, $slack_channel_name, $slack_user_name, $slack_user_icon, '#A9A9A9' );
	}

	_slack_tell( 'Importation of WordPress WP-CFM ' . $file . ' Configuration on the ' . PANTHEON_ENVIRONMENT . ' environment is complete.', $slack_channel_name, $slack_user_name, $slack_user_icon );
}

exec( 'wp cache flush' );

print( "\n==== Config Import Complete ====\n" );
