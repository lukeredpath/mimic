Feature: Configuring mimic listen options
  In order to use Mimic on platforms with mixed IPv4 and IPv6 support
  As a developer
  I want to be able to configure Mimic to listen on a specific interface
  
  Scenario: Configuring mimic to listen on all IPv4 loopback
    Given I have a mimic specification with:
      """
      Mimic.mimic(:hostname => '127.0.0.1', :port => 11988).get("/some/path").returning("Hello World")
      """
    When I make an HTTP GET request to "http://127.0.0.1:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Hello World"

  Scenario: Configuring mimic to listen on all interfaces
    Given I have a mimic specification with:
      """
      Mimic.mimic(:hostname => '0.0.0.0', :port => 11988).get("/some/path").returning("Hello World")
      """
    When I make an HTTP GET request to "http://0.0.0.0:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Hello World"
