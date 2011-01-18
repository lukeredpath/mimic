Feature: Stubbing requests by path
  In order to test requests that use specific query parameters
  As a developer
  I want to be able to only stub requests that have the correct parameters 
  
  Scenario: Accepting any parameters to a stubbed path
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Accepting specific parameters and matching
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").with_query_parameters("foo" => "bar")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with an empty body
  
  Scenario: Accepting specific parameters and matching
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").with_query_parameters("foo" => "bar")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=baz"
    Then I should receive an HTTP 404 response
  