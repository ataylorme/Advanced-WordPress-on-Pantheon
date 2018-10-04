<?php

declare(strict_types=1);

namespace PantheonSystems\WordHatHelpers\Contexts;

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\MinkExtension\Context\MinkContext;
use PaulGibbs\WordpressBehatExtension\Context\RawWordpressContext;
use PaulGibbs\WordpressBehatExtension\Context\Traits\ContentAwareContextTrait;

/**
 * Define application features from the specific context.
 */
final class GiveContext extends RawWordpressContext
{
    use ContentAwareContextTrait;

    /**
     * @When /^I set the Give donation level (?P<donation_level>[0-9]+) to "(?P<value>[^"]*)"$/
     * 
     * @param string $donation_level
     * @param string $value
     */
    public function iChangeTheGiveDonationLevel(string $donation_level, string $value)
    {
        
        /*
        * For debugging
        */
        /*
        $url = $this->getSession()->getCurrentUrl();
        echo "Viewing the page $url" . PHP_EOL;
        
        $html_data = $this->getSession()->getDriver()->getContent();
        $file_and_path = '/app/behat_output.html';
        file_put_contents($file_and_path, $html_data);
        */
        
        $selector = '_give_donation_levels_' . $donation_level . '__give_text';
        $page = $this->getSession()->getPage();
        $page->fillField($selector, $value);

    }

}