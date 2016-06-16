<?php
// Secrets helper function
require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

// An example of using Pantheon's Quicksilver technology to do
// automatic performance test using Load Impact. Adapted from
// a random GitHub done by someone at Rackspace.

// Provide the API Key and API Path provided by Load Impact
$secrets    = _get_secrets( array( 'loadimpact_key', 'loadimpact_key_v3' ) );
$api_key    = $secrets['loadimpact_key'];
$api_key_v3 = $secrets['loadimpact_key_v3'];

// Provide the Project ID for the test on Load Impact
// $test_config_id = 3359026;
$test_config_id = 3420633;

// Provide the Slack Details
$slack_channel_name = '#advanced-wordpress';
$slack_user_name    = 'PerformanceTesting-with-LoadImpact';
$slack_user_icon    = 'http://live-pantheon-wp-best-practices.pantheonsite.io/wp-content/uploads/icons/loadimpact.png';

// If we are deploying to test, run a performace test
if ( defined( 'PANTHEON_ENVIRONMENT' ) && ( PANTHEON_ENVIRONMENT == 'test' ) ) {
	echo 'Starting a performance test on the test environment...' . "\n";
	$text       = 'Performance test has started. Doing a test of 50 virtual users for 3 minutes...';
	$fields     = array(
		array(
			'title' => 'Site',
			'value' => $_ENV['PANTHEON_SITE_NAME'],
			'short' => 'true'
		),
		array(
			'title' => 'Environment',
			'value' => '<http://' . $_ENV['PANTHEON_ENVIRONMENT'] . '-' . $_ENV['PANTHEON_SITE_NAME'] . '.pantheon.io|' . $_ENV['PANTHEON_ENVIRONMENT'] . '>',
			'short' => 'true',
		),
		array(
			'title' => 'By',
			'value' => $_POST['user_email'],
			'short' => 'true',
		),
		array(
			'title' => 'Message',
			'value' => $text,
			'short' => 'false',
		),
	);
	$attachment = array(
		'fallback' => $text,
		'color'    => 'warning', // Can either be one of 'good', 'warning', 'danger', or any hex color code
		'fields'   => $fields,
	);
	_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	$curl         = curl_init();
	$curl_options = array(
		CURLOPT_URL            => 'https://api.loadimpact.com/v2/test-configs/' . $test_config_id . '/start',
		CURLOPT_USERPWD        => $api_key . ':',
		CURLOPT_HTTPAUTH       => CURLAUTH_BASIC,
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_POST           => 1,
	);
	curl_setopt_array( $curl, $curl_options );
	$curl_response = json_decode( curl_exec( $curl ) );
	curl_close( $curl );

	if ( isset( $curl_response->id ) ) {
		// Let's run a V3 Call to Get Public URL
		$curl         = curl_init();
		$curl_options = array(
			CURLOPT_URL            => 'https://api.loadimpact.com/v3/test-runs/' . $curl_response->id . '/generate_public_url',
			CURLOPT_USERPWD        => $api_key_v3 . ':',
			CURLOPT_HTTPAUTH       => CURLAUTH_BASIC,
			CURLOPT_RETURNTRANSFER => 1,
			CURLOPT_POST           => 1,
		);
		curl_setopt_array( $curl, $curl_options );
		$curl_response = json_decode( curl_exec( $curl ) );
		curl_close( $curl );

		echo 'Test results: ' . $curl_response->test_run->public_url . "\n";
		$text       = 'Visual regression test results: ' . $curl_response->test_run->public_url;
		$fields     = array(
			array(
				'title' => 'Site',
				'value' => $_ENV['PANTHEON_SITE_NAME'],
				'short' => 'true'
			),
			array(
				'title' => 'Environment',
				'value' => '<http://' . $_ENV['PANTHEON_ENVIRONMENT'] . '-' . $_ENV['PANTHEON_SITE_NAME'] . '.pantheon.io|' . $_ENV['PANTHEON_ENVIRONMENT'] . '>',
				'short' => 'true',
			),
			array(
				'title' => 'By',
				'value' => $_POST['user_email'],
				'short' => 'true',
			),
			array(
				'title' => 'Message',
				'value' => $text,
				'short' => 'false',
			),
		);
		$attachment = array(
			'fallback' => $text,
			'color'    => 'good', // Can either be one of 'good', 'warning', 'danger', or any hex color code
			'fields'   => $fields,
		);
		_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	} else {
		echo 'There has been an error: ' . ucwords( $curl_response->message ) . "\n";
	}
}