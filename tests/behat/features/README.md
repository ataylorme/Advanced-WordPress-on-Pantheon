# Sample feature files

The .feature files in this directory are meant to be a starting point for writing your own site-specific .feature files.

Feel free to delete the .feature files that come with this repo. They are present only as a reference and so that the first continuous integration builds have an automated test to run.

## Debugging
```
<?php
/*
* For debugging
*/
$url = $this->getSession()->getCurrentUrl();
echo "Viewing the page $url" . PHP_EOL;

$html_data = $this->getSession()->getDriver()->getContent();
$file_and_path = '/app/behat_output.html';
file_put_contents($file_and_path, $html_data);
```