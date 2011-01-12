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
    
  Scenario: Stubbing a path using the HTTP API
    Given that Mimic is daemonized and accepting remote configuration on "/api"
    When I make an HTTP POST request to "http://localhost:11988/api/get" with the payload:
      """
        {'path': '/anything'}
      """
    When I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 200 response with an empty body
    