Feature: Stubbing requests by path
  In order to test my app through its entire stack without depending on an external API
  As a developer
  I want to be able to stub requests to specific paths to return a canned response
  
  Scenario: Stubbing a GET request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a GET request to /some/path and returning a non-empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").returning("Hello World")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Hello World"
    
  Scenario: Requesting an un-stubbed path and getting a 404 response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path")
      """
    When I make an HTTP GET request to "http://localhost:11988/some/other/path"
    Then I should receive an HTTP 404 response with an empty body
    
  Scenario: Stubbing a POST request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).post("/some/path")
      """
    When I make an HTTP POST request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a PUT request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).put("/some/path")
      """
    When I make an HTTP PUT request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a DELETE request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).delete("/some/path")
      """
    When I make an HTTP DELETE request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a HEAD request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).head("/some/path")
      """
    When I make an HTTP HEAD request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    