Feature: Stubbing requests by path
  In order to test a range of API endpoints and HTTP verbs
  As a developer
  I want to be able to stub requests to return specific responses depending on the request method
  
  Scenario: Stubbing a POST request to return a 201 response
    Given I have a mimic specification with:
      """
      Mimic.mimic("www.example.com", 11988).post("/some/path").returning("Hello World", 201)
      """
    When I make an HTTP POST request to "http://www.example.com:11988/some/path"
    Then I should receive an HTTP 201 response with a body matching "Hello World"

  Scenario: Stubbing the same path with different responses for GET and POST
    Given I have a mimic specification with:
      """
        Mimic.mimic("www.example.com", 11988) do
          get("/some/path").returning("Some Record", 200)
          post("/some/path").returning("Created", 201)
        end
      """
    When I make an HTTP GET request to "http://www.example.com:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Some Record"
    When I make an HTTP POST request to "http://www.example.com:11988/some/path"
    Then I should receive an HTTP 201 response with a body matching "Created"
    