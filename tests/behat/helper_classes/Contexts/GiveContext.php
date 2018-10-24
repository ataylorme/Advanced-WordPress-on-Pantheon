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
     * Ordinal numbers to itegers
     *
     * @param string $ordinal_num the ordinal number, e.g. first
     * @return void|int
     */
    public function ordinalNmumberToInt( string $ordinal_num ){
        if( empty( $ordinal_num ) ){
            throw new \Exception("The ordinal cannot be empty");
        }
        
        $ordinal_num = strtolower($ordinal_num);
        
        $ordinal_numbers = array (
            'first' => 1,
            'second' => 2,
            'third' => 3,
            'fourth' => 4,
            'fifth' => 4,
            'sixth' => 5,
            'seventh' => 7,
            'eigth' => 8,
            'ninth' => 9,
            'tenth' => 10,
        );

        if( ! array_key_exists( $ordinal_num, $ordinal_numbers ) ){
            throw new \Exception("The ordinal '$ordinal_num' could not be translated to an integer");
        }

        return $ordinal_numbers[$ordinal_num];
    }

    /**
     * Donation level to number
     *
     * @param string $donation_level the ordinal donation number, e.g. first
     * @return int
     */
    private function donationLevelToNum(string $donation_level){
        return $this->ordinalNmumberToInt($donation_level) - 1;
    }

    /**
     * @When I set the :donation_level Give donation level to :value
     * 
     * @param string $donation_level
     * @param string $value
     */
    public function iChangeTheGiveDonationLevel(string $donation_level, string $value)
    {
        $donation_level = $this->donationLevelToNum($donation_level);
        $selector = '_give_donation_levels_' . $donation_level . '__give_amount';
        $page = $this->getSession()->getPage();
        $page->fillField($selector, $value);
    }
    
    /**
     * @When I set the :donation_level Give donation level as the default
     * 
     * @param string $donation_level
     */
    public function iChangeTheDefaultGiveDonationLevel(string $donation_level)
    {
        $donation_level = $this->donationLevelToNum($donation_level);
        $page = $this->getSession()->getPage();
        $radioButtonName = "_give_donation_levels[$donation_level][_give_default]";
        $radioButton = $page->find('named', ['radio', $radioButtonName]);
        if (!$radioButton) {
            throw new \Exception("Donation level $donation_level not found");
        }
        
        $select = $radioButton->getAttribute('name');
        $option = $radioButton->getAttribute('value');
        $page->selectFieldOption($select, $option);

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
    public function iGoToTheGiveFormEditScreenFor(string $title)
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
        
        $selector = '#give-amount-text';
        $this->assertSession()->elementExists('css', $selector);
        
        $page = $this->getSession()->getPage();
        $actual_value = $page->find('css', $selector)->getText();
        
        if ( $actual_value != $donation_amount ) {
            throw new \Exception("The expected donation amount of '$donation_amount' did not match the actual amount of '$actual_value'");
        }

    }
    
    /**
     * @Then I submit the Give donation form
     */
    public function submitGiveDonationForm()
    {
        $session = $this->getSession();
        $page = $session->getPage();
        $page->pressButton('give-purchase-button');
        // Looks for the '#give-email-access-form' element, giving up after 5 seconds.
        $session->wait( 5000, "document.getElementById('give-email-access-form')" );
    }

}