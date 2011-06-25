Feature: Stubbing requests from a file
  In order to pre-load Mimic with a set of stubs
  As a developer
  I want to be able to store my stub configuration in a separate file and load it in at runtime
  
  Scenario: Stubbing requests using a file
    Given the file "/tmp/test.mimic" exists with the contents:
      """
      get("/ping") { "pong" }
      """
    And I have a mimic specification with:
      """
        Mimic.mimic(:port => 11988) do
          import "/tmp/test.mimic"
        end
      """
    When I make an HTTP GET request to "http://localhost:11988/ping"
    Then I should receive an HTTP 200 response with a body matching "pong"
  
  Scenario: Stubbed requests from a file persist even when Mimic is cleared
    Given the file "/tmp/test.mimic" exists with the contents:
      """
      get("/ping") { "pong" }
      """
    And I have a mimic specification with:
      """
        Mimic.mimic(:port => 11988) do
          import "/tmp/test.mimic"
        end
        Mimic.reset_all!
      """
    When I make an HTTP GET request to "http://localhost:11988/ping"
    Then I should receive an HTTP 200 response with a body matching "pong"
    