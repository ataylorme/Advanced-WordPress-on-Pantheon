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
        $selector = '#_give_donation_levels_' . $donation_level . '__give_amount';

        // echo "Setting donation level $donation_level to $value for the $selector selector" . PHP_EOL;
        
        // $url = $this->getSession()->getCurrentUrl();
        // echo "Viewing the page $url" . PHP_EOL;

        $page = $this->getSession()->getPage();
        $element = $page->find('css', $selector);

        if (empty($element)) {
            /*
            $html_data = $this->getSession()->getDriver()->getContent();
            $file_and_path = '/app/behat_output.html';
            file_put_contents($file_and_path, $html_data);
            */
            throw new \Exception("No html element found for the selector '$selector'");
        }

        $element->setValue($value);
    }

}