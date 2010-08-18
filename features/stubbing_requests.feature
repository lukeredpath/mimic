Feature: Stubbing requests to return a response
  In order to test my app through its entire stack without depending on an external API
  As a developer
  I want to be able to stub specific requests to return a canned response
  
  Scenario: Stubbing a GET request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic("www.example.com", 11988).get("/some/path")
      """
    When I make an HTTP GET request to "http://www.example.com:11988/some/path"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a GET request to /some/path and returning a non-empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic("www.example.com", 11988).get("/some/path").returning("Hello World")
      """
    When I make an HTTP GET request to "http://www.example.com:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Hello World"
    