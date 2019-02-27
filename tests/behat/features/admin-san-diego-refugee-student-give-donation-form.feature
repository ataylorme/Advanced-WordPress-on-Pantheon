@javascript @give_wp
Feature: Manage the San Diego Refugees Donation form
  As an administrator of the site
  I want modifications made to the settings of the San Diego Refugees Donation form to be reflected on the front end of the site
  So that I can administer the San Diego Refugees Donation form

  Scenario: Confirm donation level amount and default changes
    Given I am logged in as an administrator
    And I am on the edit screen of the Give form "San Diego Refugees Donation"
    Then the "title" field should contain "San Diego Refugees Donation"
    And I should be on the edit "give_form" screen for "San Diego Refugees Donation"
    When I set the third Give donation level to "500.00"
    And I set the third Give donation level as the default
    And I press "publish"
    And I am viewing the post "San Diego Refugees Donation"
    And the cache has been cleared
    Then the default donation amount should be "500.00"