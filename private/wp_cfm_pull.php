<?php

// Pull WP-CFM "All Bundles"
echo "Pulling Pull WP-CFM 'All Bundles'...\n";
passthru('wp config pull all');
echo "Bundle pull complete.\n";

// Clear all cache
echo "Clearing cache object cache...\n";
passthru('wp cache flush');
echo "Clearing cache complete.\n";
