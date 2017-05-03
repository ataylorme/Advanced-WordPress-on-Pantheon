<?php
// Secrets helper function
require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

// An example of using Pantheon's Quicksilver technology to do
// automatic visual regression testing using Backtrac.io

// Provide the API Key provided by Backtrac.io
$secrets = _get_secrets( array( 'spotbot_key', 'slack_channel', 'live_url' ) );
$api_key = $secrets['backtrac_key'];

// Provide the Project ID for the project on Backtrac.io
$project_id = '22200';

// Provide the Slack Details
$slack_channel_name = $secrets['slack_channel'];
$slack_user_name    = 'VisualRegressionTesting-with-Backtrac';
$slack_user_icon    = $secrets['live_url'] . '/slack-icons/backtrac.png';

// If we are deploying to test, run a visual regression test 
// between the production environment and the testing environment.
if ( defined( 'PANTHEON_ENVIRONMENT' ) && ( PANTHEON_ENVIRONMENT == 'test' ) ) {
	echo 'Starting a visual regression test between the live and test environments...' . "\n";
	$text       = 'Starting a visual regression test between the live and test environments...';
	$fields     = array(
		array(
			'title' => 'Site',
			'value' => $_ENV['PANTHEON_SITE_NAME'],
			'short' => 'true'
		),
		array(
			'title' => 'Message',
			'value' => $text,
			'short' => 'false'
		),
	);
	$attachment = array(
		'fallback' => $text,
		'color'    => 'warning', // Can either be one of 'good', 'warning', 'danger', or any hex color code
		'fields'   => $fields
	);
	_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	$curl         = curl_init();
	$curl_options = array(
		CURLOPT_URL            => 'https://backtrac.io/api/project/' . $project_id . '/compare_prod_stage',
		CURLOPT_HTTPHEADER     => array( 'x-api-key: ' . $api_key ),
		CURLOPT_POST           => 1,
		CURLOPT_RETURNTRANSFER => 1,
	);
	curl_setopt_array( $curl, $curl_options );
	$curl_response = json_decode( curl_exec( $curl ) );
	curl_close( $curl );

	if ( $curl_response->status == 'success' ) {
		echo ucwords( $curl_response->status ) . ': ' . $curl_response->result->message . "\n";
		$text = 'Visual regression test between test and live complete! ' . "\n" . 'Check out the result here: ' . $curl_response->result->url;
		echo $text . "\n";
		$fields     = array(
			array(
				'title' => 'Site',
				'value' => $_ENV['PANTHEON_SITE_NAME'],
				'short' => 'true'
			),
			array(
				'title' => 'Message',
				'value' => $text,
				'short' => 'false'
			),
		);
		$attachment = array(
			'fallback' => $text,
			'color'    => 'good', // Can either be one of 'good', 'warning', 'danger', or any hex color code
			'fields'   => $fields
		);
		_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	} else {
		print_r( $curl_response );
		$text = 'Visual regression test failed! ' . "\n" . ucwords( $curl_response->status ) . ': ' . $curl_response->message;
		echo $text . "\n";
		$fields     = array(
			array(
				'title' => 'Site',
				'value' => $_ENV['PANTHEON_SITE_NAME'],
				'short' => 'true'
			),
			array(
				'title' => 'Message',
				'value' => $text,
				'short' => 'false'
			),
		);
		$attachment = array(
			'fallback' => $text,
			'color'    => 'danger', // Can either be one of 'good', 'warning', 'danger', or any hex color code
			'fields'   => $fields
		);
		_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	}
}
