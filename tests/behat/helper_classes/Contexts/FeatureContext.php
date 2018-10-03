<?php

declare(strict_types=1);

namespace PantheonSystems\WordHatHelpers\Contexts;

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\MinkExtension\Context\MinkContext;
use PaulGibbs\WordpressBehatExtension\Context\RawWordpressContext;
use PaulGibbs\WordpressBehatExtension\Context\EditPostContext;
use PaulGibbs\WordpressBehatExtension\Context\Traits\ContentAwareContextTrait;
use PaulGibbs\WordpressBehatExtension\PageObject\PostsEditPage;

/**
 * Define application features from the specific context.
 */
final class FeatureContext extends RawWordpressContext
{
    use ContentAwareContextTrait;

    /**
     * Edit post/page/post-type page (/wp-admin/post.php?post=<id>&action=edit) object.
     *
     * TODO: this needs to not be public!
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
     * @When I click the :arg1 element
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
     * Go to the edit post admin page for the referenced post title and post type.
     *
     * This step works for all post types.
     *
     * Example: Given I am on the edit screen of the "Hello World" "page"
     *
     * @Given /^I am on the edit screen of the "(?P<title>[^"]*)" "(?P<post_type>[^"]*)"$/
     *
     * @param string $title The name of the 'post' being edited.
     * @param string $post_type The post type of the 'post' being edited.
     */
    public function iGoToEditScreenFor(string $title, string $post_type)
    {
        // echo "Getting the post '$title' for the post type '$post_type'" . PHP_EOL;
        $post = $this->getContentFromTitle($title,$post_type);
        // $post = $this->getDriver()->content->get($title, ['by' => 'title', 'post_type' => $post_type]);
        $this->edit_post_page->open(array(
            'id' => $post['id'],
        ));
    }

}