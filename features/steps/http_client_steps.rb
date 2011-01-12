Before do
  @httpclient = HttpClient.new
end

When /^I make an HTTP (POST|PUT) request to "([^\"]*)" with the payload:$/ do |http_method, url, payload|
  @httpclient.perform_request_with_payload(url, http_method, payload)
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

Then /^I should receive an HTTP (\d+) response with the value "([^\"]*)" for the header "([^\"]*)"$/ do |status_code, header_value, header_key|
  @httpclient.should have_response_with_code_and_header(status_code.to_i, header_key, header_value)
end
