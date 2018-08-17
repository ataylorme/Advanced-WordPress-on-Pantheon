<?php
/*
Plugin Name: LH HSTS
Plugin URI: https://lhero.org/plugins/lh-hsts/
Description: Adds HTTP Strict Transport Security to wordpress, options can be changed by filters
Author: Peter Shaw
Version: 1.23
Author URI: https://shawfactor.com/
*/


if (!class_exists('LH_HSTS_Plugin')) {

	class  LH_HSTS_Plugin{
		private $max_age;
		private $subdomain; 
		private $preload;
		private $redirect;
		private $uri;
		private $domain;
		private $current_domain;
		
		private static $instance;
		
	/**
     * Gets an instance of our plugin.
     *
     * using the singleton pattern
     */
    public static function get_instance(){
        if (null === self::$instance) {
            self::$instance = new self();
        }
 
        return self::$instance;
    }

		function __construct() {
			add_filter( 'lh_hsts_subdomain', array($this, 'lh_hsts_subdomain_func'));
			add_filter( 'lh_hsts_preload', array($this, 'lh_hsts_preload_func'));
			add_filter( 'lh_hsts_redirect', array($this, 'lh_hsts_redirect_func'));
			add_filter( 'lh_hsts_max_age', array($this, 'lh_hsts_max_age_func'));

			$this->uri = $_SERVER['REQUEST_URI'];
			$this->domain = $_SERVER['HTTP_HOST'];
			$this->current_domain = get_home_url();

			add_action( 'send_headers', array($this, "add_header"));
		}

		public function lh_hsts_max_age_func( $max_age ){
			return $max_age;
		}

		public function lh_hsts_subdomain_func( $subdomain ){
			return $subdomain;
		}

		public function lh_hsts_preload_func( $preload ){
			return $preload;
		}

		public function lh_hsts_redirect_func( $redirect ){
			return $redirect;
		}

		public function add_header(){
		    
		 
			if($this->current_domain == "http://". $this->domain || $this->current_domain == "https://". $this->domain){
				if (isset($_SERVER['HTTPS'])){
					//default max-age in seconds (equivalent to 185 days to allow pre-loading)
					$this->max_age = apply_filters('lh_hsts_max_age', 15984000);
					$this->subdomain = apply_filters('lh_hsts_subdomain', true);
					$this->preload = apply_filters('lh_hsts_preload', true);
					$this->redirect = apply_filters('lh_hsts_redirect', true);

					$string = "max-age=".$this->max_age.";";
					if($this->subdomain){ 
						$string .= " includeSubDomains;";
					}
					if($this->preload){ 
						$string .= " preload"; 
					}

					header("Strict-Transport-Security: ". $string);
			
				} else {
				   $this->redirect = apply_filters('lh_hsts_redirect', true);
					if ($this->redirect){ 
						header('Location: https://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'], true, 301);
					}
				}
			} else {
				Header( "HTTP/1.1 301 Moved Permanently" );
				Header( "Location: ". $this->current_domain . $this->uri );
				die();
			}
		}
	}

	$LH_HSTS_Plugin_instance = LH_HSTS_Plugin::get_instance();
}

?>
