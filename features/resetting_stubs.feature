Feature: Resetting stubs
  In order to create a deterministic clean slate at the beginning of my specs
  As a developer
  I want to be able to reset all previously configured request stubs

  Scenario: Clearing a stubbed request
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").returning("Hello World", 201)
      """
    When I evaluate the code:
      """
      Mimic.reset_all!
      """
    And I make an HTTP GET request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 404 response with an empty body
  
