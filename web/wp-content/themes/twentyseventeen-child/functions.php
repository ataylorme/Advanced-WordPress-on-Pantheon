<?php
/**
 * TwentySeventeen Child Theme Functions
 * Version: 0.0.1
 *
 * @category   Child_Theme
 * @package    AdvancedWordPressOnPantheon
 * @subpackage TwentySeventeenChildTheme
 * @author     Andrew Taylor <andrew@ataylor.me>
 * @license    GPL 2.0+
 * @link       void
 */

namespace twenty_seventeen_child_theme;

/**
 * Enqueue theme script and styles
 *
 * @return void
 */
function Enqueue_Scripts_styles() 
{

    $js_deps   = array();
    $css_deps  = array();
    $js_deps[] = 'jquery';

    wp_dequeue_style('twentyseventeen-style');
    
    wp_enqueue_style(
        'twentyseventeen-style', 
        get_template_directory_uri() . '/style.css'
    );

    wp_enqueue_style(
        'twentyseventeen-child', 
        get_stylesheet_directory_uri() . '/assets/css/twentyseventeen-child.min.css'
    );

    wp_enqueue_script(
        'twentyseventeen-child', 
        get_stylesheet_directory_uri() . '/assets/js/twentyseventeen-child.min.js', 
        $js_deps, 
        false, 
        true
    );

}

add_action('wp_enqueue_scripts', __NAMESPACE__ . '\Enqueue_Scripts_styles');