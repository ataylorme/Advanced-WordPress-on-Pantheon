<?php

declare(strict_types=1);

namespace PantheonSystems\WordHatHelpers\Contexts;

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\MinkExtension\Context\MinkContext;
use PaulGibbs\WordpressBehatExtension\Context\RawWordpressContext;
use PaulGibbs\WordpressBehatExtension\Context\Traits\ContentAwareContextTrait;
use PaulGibbs\WordpressBehatExtension\PageObject\PostsEditPage;
use Behat\Mink\Exception\ExpectationException;
use PaulGibbs\WordpressBehatExtension\Context\Traits\UserAwareContextTrait;

/**
 * Define application features from the specific context.
 */
final class GiveContext extends RawWordpressContext
{
    use ContentAwareContextTrait;
    use UserAwareContextTrait;

    /**
     * Edit post/page/post-type page (/wp-admin/post.php?post=<id>&action=edit) object.
     *
     * @var PostsEditPage
     */
    public $edit_post_page;

    /**
     * Constructor.
     *
     * @param PostsEditPage $edit_post_page The page object representing the edit post page.
     */
    public function __construct(PostsEditPage $edit_post_page)
    {
        parent::__construct();
        $this->edit_post_page = $edit_post_page;
    }

    /**
     * @When I set the Give donation level :donation_level to :value
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
        
        $selector = '_give_donation_levels_' . $donation_level . '__give_amount';
        $page = $this->getSession()->getPage();
        $page->fillField($selector, $value);

    }

     /**
     * Go to the edit post admin page for the Give form referenced by post title.
     *
     * Example: Given I am on the edit screen of the Give form "Hello World"
     *
     * @Given I am on the edit screen of the Give form :title
     *
     * @param string $title The name of the 'post' being edited.
     */
    public function iGoToEditScreenFor(string $title)
    {
        $post = $this->getContentFromTitle($title,'give_forms');
        $this->edit_post_page->open(array(
            'id' => $post['id'],
        ));
    }
    
    /**
     * @Then the default donation amount should be :donation_amount
     * 
     * @param string $donation_amount
     */
    public function checkDefaultDonationAmount(string $donation_amount)
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
        
        $selector = '#give-amount-text';
        $this->assertSession()->elementExists('css', $selector);
        
        $page = $this->getSession()->getPage();
        $actual_value = $page->find('css', $selector)->getText();
        
        if ( $actual_value != $donation_amount ) {
            throw new \Exception("The expected donation amount of '$donation_amount' did not match the actual amount of '$actual_value'");
        }

    }

}