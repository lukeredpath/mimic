Feature: Echoing request in response
  In order to easily verify that I sent the correct request data
  As a developer
  I want to tell mimic to echo the request data in a specific format in it's response
  
  Scenario: Echoing query parameters in JSON format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").echo_request!(:json)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with the JSON value "bar" for the key path "echo.params.foo"
    
  Scenario: Echoing request headers in JSON format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").echo_request!(:json)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path" with the header "X-TEST: Some Value"
    Then I should receive an HTTP 200 response with the JSON value "Some Value" for the key path "echo.env.HTTP_X_TEST"
    
  Scenario: Echoing request body in JSON format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).post("/some/path").echo_request!(:json)
      """
    When I make an HTTP POST request to "http://localhost:11988/some/path" with the payload:
      """
      REQUEST BODY
      """
    Then I should receive an HTTP 200 response with the JSON value "REQUEST BODY" for the key path "echo.body"

  Scenario: Echoing query parameters in Plist format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").echo_request!(:plist)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with the Plist value "bar" for the key path "echo.params.foo"

  Scenario: Echoing request headers in Plist format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").echo_request!(:plist)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path" with the header "X-TEST: Some Value"
    Then I should receive an HTTP 200 response with the Plist value "Some Value" for the key path "echo.env.HTTP_X_TEST"

  Scenario: Echoing request body in Plist format
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).post("/some/path").echo_request!(:plist)
      """
    When I make an HTTP POST request to "http://localhost:11988/some/path" with the payload:
      """
      REQUEST BODY
      """
    Then I should receive an HTTP 200 response with the Plist value "REQUEST BODY" for the key path "echo.body"
    
  Scenario: Echoing query parameters but also specifying a response body results in response body being overwritten
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").returning("not an echo").echo_request!(:json)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with the JSON value "bar" for the key path "echo.params.foo"
    
  Scenario: Echoing response manually from block definition
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path") do
        echo_request!(:json)
      end
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with the JSON value "bar" for the key path "echo.params.foo"
    