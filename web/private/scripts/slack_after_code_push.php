<?php
// Load Slack helper functions
require_once( dirname( __FILE__ ) . '/slack_helper.php' );

if ( isset( $_POST['wf_type'] ) && $_POST['wf_type'] == 'sync_code' ) {
	// Get the committer, hash, and message for the most recent commit.
	$committer = `git log -1 --pretty=%cn`;
	$email     = `git log -1 --pretty=%ce`;
	$message   = `git log -1 --pretty=%B`;
	$hash      = `git log -1 --pretty=%h`;

	// Setup the Text
	$text       = 'Git commit (' . rtrim( $hash ) . ') with message "' . rtrim( $message ) . '"';
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
			'value' => $committer . ' (' . $email . ')',
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
		'color'    => '#EFD01B', // Can either be one of 'good', 'warning', 'danger', or any hex color code
		'fields'   => $fields,
	);
	_slack_tell( $text, '#advanced-wordpress', 'Git-on-Pantheon', 'http://live-pantheon-wp-best-practices.pantheonsite.io/wp-content/uploads/icons/git.png', false, $attachment );
}
