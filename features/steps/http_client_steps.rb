Before do
  @httpclient = HttpClient.new
end

When /^I make an HTTP (GET|POST|PUT|DELETE|HEAD) request to "([^\"]*)"$/ do |http_method, url|
  @httpclient.perform_request(url, http_method)
end

Then /^I should receive an HTTP (\d+) response with an empty body$/ do |status_code|
  steps %Q{
    Then I should receive an HTTP #{status_code} response with a body matching ""
  }
end

Then /^I should receive an HTTP (\d+) response with a body matching "([^\"]*)"$/ do |status_code, http_body|
  @httpclient.should have_response_with_code_and_body(status_code.to_i, http_body)
end

Then /^I should receive an HTTP (\d+) response$/ do |status_code|
  @httpclient.should have_response_with_code(status_code.to_i)
end

