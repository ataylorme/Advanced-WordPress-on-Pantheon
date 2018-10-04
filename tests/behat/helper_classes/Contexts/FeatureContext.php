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
     * Log user in as an admin.
     *
     * Example: Given I am an admin
     *
     * @Given I am an admin
     *
     * @throws \RuntimeException
     */
    public function iAmAnAdmin()
    {
        $role = 'administrator';
        $found_user = null;
        $users      = $this->getWordpressParameter('users');
        foreach ($users as $user) {
            if (in_array($role, $user['roles'], true)) {
                $found_user = $user;
                break;
            }
        }
        if ($found_user === null) {
            throw new RuntimeException("[W801] User not found for role \"{$role}\"");
        }

        $username = $found_user['username'];
        $password = $found_user['password'];
        

        if ($this->loggedIn()) {
            $this->logOut();
        }
        
        $this->visitPath('wp-login.php');
        $session = $this->getSession();
        $page = $session->getPage();

        /*
        * For debugging
        */
        $url = $session->getCurrentUrl();
        echo "Viewing the page $url" . PHP_EOL;

        $page->fillField('user_login', $username);
        $page->fillField('user_pass', $password);
        
        $html_data = $session->getDriver()->getContent();
        $file_and_path = '/app/behat_output.html';
        file_put_contents($file_and_path, $html_data);
        
        /*
        $node = $page->findField('user_login');
        
        try {
            $node->focus();
        } catch (UnsupportedDriverActionException $e) {
            // This will fail for GoutteDriver but neither is it necessary.
        }
        
        // This is to make sure value is set properly.
        $node->setValue('');
        $node->setValue($username);
        $node->setValue($username);
        $node = $page->findField('user_pass');
        
        try {
            $node->focus();
        } catch (UnsupportedDriverActionException $e) {
            // This will fail for GoutteDriver but neither is it necessary.
        }

        // This is to make sure value is set properly.
        $node->setValue('');
        $node->setValue($password);
        $node->setValue($password);
        */

        $page->findButton('wp-submit')->click();
        if (! $this->loggedIn()) {
            throw new ExpectationException('[W803] The user could not be logged-in.', $this->getSession()->getDriver());
        }
    }

}