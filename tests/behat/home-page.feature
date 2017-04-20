Feature: Home Page

  Background:
	Given I log in as an admin

  Scenario: Title
	When I go to "/"
	Then I should see "Pantheon WP Best Practices" in the "h1 a" element