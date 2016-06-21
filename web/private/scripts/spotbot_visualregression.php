<?php
// Secrets helper function
require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

// An example of using Pantheon's Quicksilver technology to do
// automatic visual regression testing using Spotbot.qa

// Provide the API Key provided by Spotbot.qa
$secrets = _get_secrets( array( 'spotbot_key', 'slack_channel', 'live_url', 'test_url' ) );
$api_key = $secrets['spotbot_key'];

// Provide the Project URL for the project on Spotbot.qa
$project_url = $secrets['test_url'];

// Provide the Slack Details
$slack_channel_name = $secrets['slack_channel'];
$slack_user_name    = 'CrossBrowserTesting-with-Spotbot';
$slack_user_icon    = $secrets['live_url'] . '/wp-content/uploads/icons/spotbot.png';

// If we are deploying to test, run a visual regression test
// between the production environment and the testing environment.
if ( defined( 'PANTHEON_ENVIRONMENT' ) && ( PANTHEON_ENVIRONMENT == 'test' ) ) {
	echo 'Kicking off browser testing for the test site...' . "\n";
	$curl         = curl_init();
	$curl_options = array(
		CURLOPT_URL            => 'https://spotbot.qa/api/scans',
		CURLOPT_HTTPHEADER     => array( 'Authorization: ' . $api_key ),
		CURLOPT_POST           => 1,
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_POST           => 1,
		CURLOPT_POSTFIELDS     => 'pageUrl=' . urlencode( $project_url ),
	);
	curl_setopt_array( $curl, $curl_options );
	$curl_response = json_decode( curl_exec( $curl ) );
	curl_close( $curl );

	if ( $curl_response->status == 'ok' ) {
		echo "Check out the result here: " . $curl_response->result[0]->url . "\n";
		$text       = 'Kicking off a cross browser test using Chrome, Firefox, Internet Explorer, Android, and iOS...';
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
			array(
				'title' => 'Results',
				'value' => $curl_response->result[0]->url,
				'short' => false,
			),
		);
		$attachment = array(
			'fallback' => $text,
			'color'    => 'good', // Can either be one of 'good', 'warning', 'danger', or any hex color code
			'fields'   => $fields,
		);
		_slack_tell( $text, $slack_channel_name, $slack_user_name, $slack_user_icon, false, $attachment );
	} else {
		echo ucwords( $curl_response->status ) . ': ' . $curl_response->error->message . "\n";
	}
}