Feature: Configuring Mimic via an HTTP interface
  In order to use Mimic stubs from non-Ruby test cases
  As a developer
  I want to be able to configure a background Mimic process using an HTTP REST API
    
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
    When I make an HTTP POST request to "http://localhost:11988/api/put" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP PUT request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body

  Scenario: Stubbing a request path via DELETE the HTTP API for a
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/delete" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP DELETE request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Stubbing a request path via HEAD using the HTTP API
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/head" with the payload:
      """
        {"path": "/anything"}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP HEAD request to "http://localhost:11988/anything"
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
    
  Scenario: Stubbing a request using the HTTP API in plist format
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request with a "application/plist" content-type to "http://localhost:11988/api/get" and the payload:
      """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>path</key>
          <string>/anything</string>
        </dict>
        </plist>
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Configuring multiple stubs for a single verb in a single request
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {"stubs":[{"path": "/anything"}, {"path": "/something"}]}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    And I make an HTTP GET request to "http://localhost:11988/something"
    Then I should receive an HTTP 200 response with an empty body
    
  Scenario: Configuring multiple stubs for different verbs in a single request
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/multi" with the payload:
      """
        {"stubs":[{"method": "GET", "path": "/anything"}, {"method": "POST", "path": "/something"}]}
      """
    Then I should receive an HTTP 201 response
    And I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    And I make an HTTP POST request to "http://localhost:11988/something"
    Then I should receive an HTTP 200 response with an empty body
    