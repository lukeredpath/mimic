Feature: Configuring Mimic via an HTTP interface
  In order to use Mimic stubs from non-Ruby test cases
  As a developer
  I want to be able to configure Mimic to run in the background and configure it using HTTP/REST
  
  Scenario: Starting Mimic in the background with no pre-configured stubs
    Given I execute the script:
      """
      Mimic.daemonize({:port => 11988, :remote_configuration_path => '/api'}, :ARGV => ['run'])
      """
    When I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 404 response with an empty body
    
  Scenario: Stubbing a request path via GET using the HTTP API
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a request path via POST the HTTP API for a
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/post" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP POST request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
  
  Scenario: Stubbing a request path via PUT using the HTTP API
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body

  Scenario: Stubbing a request path via DELETE the HTTP API for a
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/post" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP POST request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a request path via DELETE using the HTTP API
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body

  Scenario: Stubbing a request path to return a custom response body
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything", "body": "Hello World"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with a body matching "Hello World"
    
  Scenario: Stubbing a request path to return a custom status code
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything", "code": 301}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 301 response with an empty body
    
  Scenario: Stubbing a request path to return custom headers
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"path": "/anything", "headers": {"X-TEST-HEADER": "TESTING"}}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with the value "TESTING" for the header "X-TEST-HEADER"
    