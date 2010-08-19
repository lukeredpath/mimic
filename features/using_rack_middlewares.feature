Feature: Injecting Rack middleware into the request chain for a stub
  In order to test common scenarios (e.g. authentication)
  As a developer
  I want to be able to use Rack middlewares for certain responses
  
  Scenario: Using Rack::Auth to simulate failed authentication
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988) do
        use Rack::Auth::Basic do |username, password|
        end
        
        get("/some/path")
      end
      """
    When I make an HTTP GET request to "http://localhost:11988/some/path"
    Then I should receive an HTTP 401 response
    
  Scenario: Using Rack::Auth to simulate successful authentication
    Given I have a mimic specification with:
      """
      Mimic.mimic(:port => 11988) do
        use Rack::Auth::Basic do |username, password|
          username == 'test' && password == 'pass'
        end

        get("/some/path")
      end
      """
    When I make an HTTP GET request to "http://test:pass@localhost:11988/some/path"
    Then I should receive an HTTP 200 response