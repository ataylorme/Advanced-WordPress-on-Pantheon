<?php
if ( 'test' === $_ENV['PANTHEON_ENVIRONMENT'] ) {
	// Secrets helper function
	require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

	$secrets = _get_secrets( array( 'circle_ci_token', 'circle_ci_project', 'circle_ci_branch' ) );

	$circle_ci_project = $secrets[ 'circle_ci_project' ];
	$circle_ci_branch  = $secrets[ 'circle_ci_branch' ];
	$circle_ci_token   = $secrets[ 'circle_ci_token' ];

	$trigger_build_url = 'https://circleci.com/api/v1.1/project/github/' . $circle_ci_project . '/tree/' . $circle_ci_branch . '?circle-token=' . $circle_ci_token;

	$pantheon_test_url = 'http://' . $_ENV['PANTHEON_ENVIRONMENT'] . '-' . $_ENV['PANTHEON_SITE_NAME'] . '.pantheonsite.io';

	echo "===== Triggering Circle CI build for the project '$circle_ci_project' on the $circle_ci_branch branch with RUN_BEHAT_BUILD and PANTHEON_TEST_URL =====\n";

	$settings = array(
		'build_parameters' => array(
			'RUN_BEHAT_BUILD' => true,
			'BEHAT_ENV' => $_ENV['PANTHEON_ENVIRONMENT'],
			'BEHAT_TEST_URL' => $pantheon_test_url,
		),
	);

	$data_json = json_encode( $settings );

	$ch = curl_init();
	curl_setopt( $ch, CURLOPT_URL, $trigger_build_url );
	curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1 );
	curl_setopt( $ch, CURLOPT_POSTFIELDS, $data_json );
	curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, "POST" );
	$headers = [
		'Accept: application/json',
		'Content-Type: application/json'
	];
	curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
	$result = curl_exec( $ch );
	if ( curl_errno( $ch ) ) {
		echo 'Error:' . curl_error( $ch );
	}
	curl_close( $ch );
}
