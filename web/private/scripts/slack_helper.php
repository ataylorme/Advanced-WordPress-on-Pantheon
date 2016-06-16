<?php
#### SLACK INTEGRATION ####
$pantheon_yellow = '#EFD01B';

// Secrets helper function
if( !function_exists('_get_secrets') ){
	require_once( dirname( __FILE__ ) . '/secrets_helper.php' );
}

/**
 * Helper Function to Alert Slack
 */
function _slack_tell( $message, $slack_channel_name, $slack_user_name, $slack_icon_url, $left_color_bar = false, $attachment = false ) {
	$defaults = array();
	$secrets  = _get_secrets( array( 'slack_url' ), $defaults );
	_slack_notification( $secrets['slack_url'], $slack_channel_name, $slack_user_name, $message, $slack_icon_url, $left_color_bar, $attachment );
}

/**
 * Send a notification to slack
 */
function _slack_notification( $slack_url, $channel, $username, $text, $icon_url, $left_color_bar = false, $attachment = false ) {
	$post = array(
		'username' => $username,
		'channel'  => $channel,
		'icon_url' => $icon_url,
	);

	if ( $left_color_bar !== false ) {
		$post['attachments'] = array(
			array(
				'fallback' => $text,
				'color'    => $left_color_bar,
				'text'     => $text,
			),
		);
	} else if ( $attachment !== false && is_array( $attachment ) ) {
		$post['attachments'] = array( $attachment );
	} else {
		$post['text'] = $text;
	}
	$payload = json_encode( $post );
	$ch      = curl_init();
	curl_setopt( $ch, CURLOPT_URL, $slack_url );
	curl_setopt( $ch, CURLOPT_POST, 1 );
	curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1 );
	curl_setopt( $ch, CURLOPT_TIMEOUT, 5 );
	curl_setopt( $ch, CURLOPT_HTTPHEADER, array( 'Content-Type: application/json' ) );
	curl_setopt( $ch, CURLOPT_POSTFIELDS, $payload );
	// Watch for messages with `terminus workflows watch --site=SITENAME`
	print( "\n==== Posting to Slack ====\n" );
	$result = curl_exec( $ch );
	print( "\n===== Slack Posting Complete! =====\n" );
	curl_close( $ch );
}
