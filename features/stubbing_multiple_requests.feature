Feature: Stubbing multiple reuquests
  In order to register mutliple requests without using the same do-block
  As a developer
  I want to be able to register multiple request stubs individually

    Scenario: Stubbing two GET requests to different URLs
    When I evaluate the code:
      """
      Mimic.mimic.get("/some/path").returning("Hello World")
      """
    And I make an HTTP GET request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 200 response with a body matching "Hello World"
    When I evaluate the code:
      """
      Mimic.mimic.get("/some/other/path").returning("Foo bar")
      """
    And I make an HTTP GET request to "http://localhost:11988/some/other/path"
    Then I should receive an HTTP 200 response with a body matching "Foo bar"