Feature: Change blogname and blogdescription (no-js)
  As a maintainer of the site
  I want to be able to change basic settings
  So that I have control over my site

  Background:
    Given I am logged in as an administrator
    Given I am on the dashboard

  Scenario: Saving blogname
    Given I go to the menu "Settings > General"
    When I fill in "blogname" with "Give Behat Demo"
    And I press "submit"
    And I should see "Settings saved."
    And I am on the homepage
    Then I should see "Give Behat Demo" in the "h1 a" element

  Scenario: Saving blogdescription
    Given I go to the menu "Settings > General"
    When I fill in "blogdescription" with "Behat tests rock!"
    And I press "submit"
    And I should see "Settings saved."
    And I am on the homepage
    Then I should see "Behat tests rock!" in the ".site-description" element