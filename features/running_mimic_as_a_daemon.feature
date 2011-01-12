Feature: Running Mimic as a daemon
  In order to use Mimic out of process
  As a developer
  I want to be able to start Mimic as a background daemon

  Scenario: Starting Mimic in the background with no pre-configured stubs
    Given I execute the script:
      """
      Mimic.daemonize({:port => 11988, :remote_configuration_path => '/api'}, :ARGV => ['run'])
      """
    When I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 404 response with an empty body
    
  Scenario: Starting Mimic in the background with pre-configured stubs
    Given I execute the script:
      """
      Mimic.daemonize({:port => 11988, :remote_configuration_path => '/api'}, :ARGV => ['run']) do
        get("/preconfigured").returning("test response")
      end
      """
    When I make an HTTP GET request to "http://localhost:11988/preconfigured"
    Then I should receive an HTTP 200 response with a body matching "test response"
