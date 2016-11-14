<?php
namespace twenty_sixteen_child_theme;

function enqueue_scripts_styles() {

	$js_deps   = $css_deps = array();
	$js_deps[] = 'jquery';

	wp_dequeue_style( 'twentysixteen-style' );
	wp_enqueue_style( 'twentysixteen-style', get_template_directory_uri() . '/style.css' );
	wp_enqueue_style( 'twentysixteen-child', get_stylesheet_directory_uri() . '/assets/css/twentysixteen-child.min.css' );

	wp_enqueue_script( 'twentysixteen-child', get_stylesheet_directory_uri() . '/assets/js/twentysixteen-child.min.js', $js_deps, false, true );
}

add_action( 'wp_enqueue_scripts', __NAMESPACE__ . '\enqueue_scripts_styles' );

function add_browser_sync_snippet_to_footer() {
	echo '<script type=\'text/javascript\' id="__bs_script__">//<![CDATA[' . PHP_EOL;
	echo "\t" . 'document.write("<script async src=\'http://HOST:3000/browser-sync/browser-sync-client.2.13.0.js\'><\/script>".replace("HOST", location.hostname));' . PHP_EOL;
	echo '//]]></script>' . PHP_EOL;
}

if ( IS_LOCAL ) {
	add_action( 'wp_footer', __NAMESPACE__ . '\add_browser_sync_snippet_to_footer' );
}
