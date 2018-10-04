@javascript
Feature: Manage the San Diego Refugees Donation form
  As an administrator of the site
  I want modifications made to the settings of the San Diego Refugees Donation form to be reflected on the front end of the site
  So that I can administer the San Diego Refugees Donation form

Background:
    #Given I am an admin
    Given I am logged in as an administrator
    Given the give plugin is active
    #Given I am on the edit screen of the post 1269
    Given I am on the edit screen for "San Diego Refugees Donation"

  Scenario: Confirm we are on the correct donations page
    Then the "title" field should contain "San Diego Refugees Donation"
    And I should be on the edit "give_form" screen for "San Diego Refugees Donation"

  Scenario: Confirm donation level amount changes
    When I set the Give donation level 0 to "25.00"
    And I set the Give donation level 1 to "100.00"
    And I set the Give donation level 2 to "250.00"
    And I press "publish"
    And I am on "San Diego Refugees Donation"
    Then the "give-amount-text" element should contain "100.00"