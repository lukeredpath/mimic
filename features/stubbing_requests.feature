Feature: Stubbing requests to return a response
  In order to test my app through its entire stack without depending on an external API
  As a developer
  I want to be able to stub specific requests to return a canned response
  
  Scenario: Stubbing a GET request to /some/path and return an empty response
    Given I have a mimic specification with:
      """
      Mimic.mimic("api.twitter.com").get("/1/statuses/public_timeline.json")
      """
    When I make an HTTP GET request to "http://api.twitter.com/1/statuses/public_timeline.json"
    Then I should receive an HTTP 200 response with an empty body
    