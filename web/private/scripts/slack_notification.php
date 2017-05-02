<?php
// Secrets helper function
require_once( dirname( __FILE__ ) . '/secrets_helper.php' );

// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

$secrets = _get_secrets( array( 'slack_channel', 'live_url' ) );

// Important constants :)
$pantheon_yellow = '#EFD01B';

// Default values for parameters
$defaults = array(
	'slack_channel'  => $secrets['slack_channel'],
	'slack_username' => 'Deploy-on-Pantheon',
	'slack_icon'     => $slack_user_icon = $secrets['live_url'] . '/slack-icons/pantheon.png',
);

// Load our hidden credentials.
// See the README.md for instructions on storing secrets.
$secrets = _get_secrets( array( 'slack_url' ), $defaults );

// Build an array of fields to be rendered with Slack Attachments as a table
// attachment-style formatting:
// https://api.slack.com/docs/attachments
$fields = array(
	array(
		'title' => 'Site',
		'value' => $_ENV['PANTHEON_SITE_NAME'],
		'short' => 'true'
	),
	array( // Render Environment name with link to site, <http://{ENV}-{SITENAME}.pantheonsite.io|{ENV}>
		'title' => 'Environment',
		'value' => '<http://' . $_ENV['PANTHEON_ENVIRONMENT'] . '-' . $_ENV['PANTHEON_SITE_NAME'] . '.pantheonsite.io|' . $_ENV['PANTHEON_ENVIRONMENT'] . '>',
		'short' => 'true'
	),
	array( // Render Name with link to Email from Commit message
		'title' => 'By',
		'value' => $_POST['user_email'],
		'short' => 'true'
	),
);

// Customize the message based on the workflow type.  Note that slack_notification.php
// must appear in your pantheon.yml for each workflow type you wish to send notifications on.
switch ( $_POST['wf_type'] ) {
	case 'deploy':
		// Find out what tag we are on and get the annotation.
		$deploy_tag     = `git describe --tags`;
		$deploy_message = $_POST['deploy_message'];

		// Prepare the slack payload as per:
		// https://api.slack.com/incoming-webhooks
		$text = $deploy_message;
		// Build an array of fields to be rendered with Slack Attachments as a table
		// attachment-style formatting:
		// https://api.slack.com/docs/attachments
		$fields[] = array(
			'title' => 'Deploy Message',
			'value' => $text,
			'short' => 'false'
		);
		break;

	case 'sync_code':
		// Get the committer, hash, and message for the most recent commit.
		$committer = `git log -1 --pretty=%cn`;
		$email     = `git log -1 --pretty=%ce`;
		$message   = `git log -1 --pretty=%B`;
		$hash      = `git log -1 --pretty=%h`;

		// Prepare the slack payload as per:
		// https://api.slack.com/incoming-webhooks
		$text = 'Code sync to the ' . $_ENV['PANTHEON_ENVIRONMENT'] . ' environment of ' . $_ENV['PANTHEON_SITE_NAME'] . ' by ' . $_POST['user_email'] . "!\n";
		$text .= 'Most recent commit: ' . rtrim( $hash ) . ' by ' . rtrim( $committer ) . ': ' . $message;
		// Build an array of fields to be rendered with Slack Attachments as a table
		// attachment-style formatting:
		// https://api.slack.com/docs/attachments
		$fields += array(
			array(
				'title' => 'Commit',
				'value' => rtrim( $hash ),
				'short' => 'true'
			),
			array(
				'title' => 'Commit Message',
				'value' => $message,
				'short' => 'false'
			)
		);
		break;

	default:
		$text = $_POST['qs_description'];
		break;
}

$attachment = array(
	'fallback' => $text,
	'color'    => $pantheon_yellow, // Can either be one of 'good', 'warning', 'danger', or any hex color code
	'fields'   => $fields
);

_slack_notification( $secrets['slack_url'], $secrets['slack_channel'], $secrets['slack_username'], $text, $secrets['slack_icon'], false, $attachment );
