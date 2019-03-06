@javascript @give_wp @form
Feature: Verify the San Diego Refugees Donation form
  I want to verify submission of the San Diego Refugees Donation form

  Scenario: Confirm donation submissions
    Given I am viewing the post "San Diego Refugees Donation"
    When I set the Give first name to "Andrew"
    And I set the Give last name to "Taylor"
    And I set the Give email to "andrew@pantheon.io"
    And I submit the Give donation form
    And I should be on "/donation-confirmation/"
    And I should see "Donation Confirmation"
    Given I am logged in as an administrator
    Given I am editing the latest Give donation
    Then I should see "Complete"
    And I should see "andrew@pantheon.io"