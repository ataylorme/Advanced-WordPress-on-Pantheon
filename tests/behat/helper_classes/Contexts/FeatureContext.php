<?php

declare(strict_types=1);

namespace PantheonSystems\WordHatHelpers\Contexts;

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\MinkExtension\Context\MinkContext;
use PaulGibbs\WordpressBehatExtension\Context\RawWordpressContext;
use PaulGibbs\WordpressBehatExtension\Context\EditPostContext;
use PaulGibbs\WordpressBehatExtension\Context\Traits\ContentAwareContextTrait;
use PaulGibbs\WordpressBehatExtension\Context\Traits\UserAwareContextTrait;
use PaulGibbs\WordpressBehatExtension\PageObject\PostsEditPage;
use Behat\Mink\Exception\ExpectationException;

/**
 * Define application features from the specific context.
 */
final class FeatureContext extends RawWordpressContext
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
     * @When I click the :selector element
     * 
     * @param string $selector
     */
    public function iClickTheElement(string $selector)
    {
        $page = $this->getSession()->getPage();
        $element = $page->find('css', $selector);

        if (empty($element)) {
            throw new \Exception("No html element found for the selector '$selector'");
        }

        $element->click();
    }

    /**
     * @When /^I check the "([^"]*)" radio button$/
     */
    public function iCheckTheRadioButton($labelText)
    {
        $page = $this->getSession()->getPage();
        $radioButton = $page->find('named', ['radio', $labelText]);
        if ($radioButton) {
            $select = $radioButton->getAttribute('name');
            $option = $radioButton->getAttribute('value');
            $page->selectFieldOption($select, $option);
            return;
        }

        throw new \Exception(
            "Radio button with label {$labelText} not found"
        );
    }

     /**
     * Go to the edit post admin page for the referenced post title and post type.
     *
     * This step works for all post types.
     *
     * Example: Given I am on the edit screen of the "Hello World" "page"
     *
     * @Given I am on the edit screen of the :title :post_type
     *
     * @param string $title The name of the 'post' being edited.
     * @param string $post_type The post type of the 'post' being edited.
     */
    public function iGoToEditScreenFor(string $title, string $post_type)
    {
        $post = $this->getContentFromTitle($title,$post_type);
        $this->edit_post_page->open(array(
            'id' => $post['id'],
        ));
    }
     
    /**
     * Go to the edit post admin page for the referenced by post ID.
     *
     * This step works for all post types.
     *
     * Example: Given I am on the edit screen of the post 1234
     *
     * @Given I am on the edit screen of the post :post_id
     *
     * @param string $post_id The ID of the 'post' being edited.
     */
    public function iGoToEditScreenForPostID(string $post_id)
    {
        $this->edit_post_page->open(array(
            'id' => (int) $post_id,
        ));
    }

    /**
     * Go to a specific post by ID
     *
     * Example: Given I am viewing the post with an ID of 1234
     *
     * @Given I am viewing the post with an ID of :post_id
     *
     * @param string $post_id
     *
     * @throws \UnexpectedValueException
     */
    public function iAmViewingPostID($post_id)
    {
        $post = $this->getDriver()->content->get(
            $post_id, ['by' => 'ID']
        );
        $this->visitPath($post->url);
    }

    /**
     * @Then I wait for the element with the id :element to appear
     *
     * @param string $element
     */
    public function waitForElementToAppear(string $element) {
        $this->getSession()->wait( 5000, "document.getElementById('$element')" );
    }

    /**
     * Go to the edit post admin page for the latest post of a specific post status and post type.
     *
     * This step allows you to specify the post type to consider.
     * This step allows you to specify the post status to consider.
     *
     * Example: Given I am editing the latest published post
     * Example: Given I am editing the latest draft event
     * Example: Given I am editing the latest scheduled post
     *
     * @Given /^I am editing the latest ([a-z_-]+) ([a-z_-]+)$/
     *
     * @param string $post_status The post status of the referenced 'post' being edited.
     * @param string $post_type The post type of the referenced 'post' being edited.
     */
    public function iEditTheLatestPostOfPostTypeAndStatus(string $post_status='publish', string $post_type)
    {

        /**
         * Removed "ed" from the end of $post_status if it is present.
         * This allows words like "published" to be translated into the proper post status.
         */
        $post_status_ending = substr($post_status, -2);
        if ( 'ed' == $post_status_ending ) {
            $post_status = substr($post_status, 0, -2);
        }

        $args = array (
            "--post_type=$post_type",
            '--field=ID',
            '--orderby=date',
            '--order=DESC',
            "--post_status=$post_status",
            '--posts_per_page=1',
            '--ignore_sticky_posts=1',
        );
        
        $wpcli_output = $this->getDriver()->wpcli('post', 'list', $args);

        // Throw an exception if the result from wp-cli is empty or is not number.
        if( 
            empty( $wpcli_output['stdout'] ) || 
            1 !== preg_match( '/^[0-9]+$/', $wpcli_output['stdout'] ) 
        ){
            throw new \Exception("No posts with the post type '$post_type' and post status '$post_status' found");
        }

        $post_id = (int) $wpcli_output['stdout'];

        echo "Opening post with the ID $post_id\n";
        
        $this->edit_post_page->open(array(
            'id' => $post_id,
        ));
    }

}