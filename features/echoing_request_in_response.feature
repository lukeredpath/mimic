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

  Scenario: Echoing query parameters but also specifying a response body results in response body being overwritten
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988).get("/some/path").returning("not an echo").echo_request!(:json)
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path?foo=bar"
    Then I should receive an HTTP 200 response with the JSON value "bar" for the key path "echo.params.foo"