Feature: Running Mimic as a daemon
  In order to use Mimic out of process
  As a developer
  I want to be able to start Mimic as a background daemon

  Scenario: Starting Mimic in the background with no pre-configured stubs
    Given I execute the script:
      """
      Mimic.daemonize({:port => 11988}, :ARGV => ['run'])
      """
    When I make an HTTP GET request to "http://localhost:11988/anything"
    Then I should receive an HTTP 404 response with an empty body
    
  Scenario: Starting Mimic in the background with pre-configured stubs
    Given I execute the script:
      """
      Mimic.daemonize({:port => 11988}, :ARGV => ['run']) do
        get("/preconfigured").returning("test response")
      end
      """
    When I make an HTTP GET request to "http://localhost:11988/preconfigured"
    Then I should receive an HTTP 200 response with a body matching "test response"

  Scenario: Starting Mimic in the background with pre-configured stubs in a file
    Given the file "/tmp/test_stubs.rb" exists with the contents:
      """
      get("/stub_one").returning("test response")
      """
    When I execute the script:
      """
      Mimic.daemonize({:port => 11988, :stub_file => "/tmp/test_stubs.rb"}, :ARGV => ['run'])
      """
    And I make an HTTP GET request to "http://localhost:11988/stub_one"
    Then I should receive an HTTP 200 response with a body matching "test response"
    