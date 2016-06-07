Before do
  @httpclient = HttpClient.new
end

def headers_from_string(string)
  string.split("\n").inject({}) do |headers, header_string|
    headers.tap do |h|
      components = header_string.split(":")
      h[components[0].strip] = components[1].strip
    end
  end
end

When /^I make an HTTP (POST|PUT) request to "([^\"]*)" with the payload:$/ do |http_method, url, payload|
  @httpclient.perform_request_with_payload(url, http_method, payload)
end

When /^I make an HTTP (POST|PUT) request with a "([^\"]*)" content-type to "([^\"]*)" and the payload:$/ do |http_method, content_type, url, payload|
  @httpclient.perform_request_with_payload(url, http_method, payload, :content_type => content_type)
end

When /^I make an HTTP (GET|POST|PUT|DELETE|HEAD) request to "([^\"]*)"$/ do |http_method, url|
  @httpclient.perform_request(url, http_method)
end

When /^I make an HTTP (GET|POST|PUT|DELETE|HEAD) request to "([^\"]*)" with the header "([^\"]*)"$/ do |http_method, url, header|
  @httpclient.perform_request(url, http_method, nil, headers_from_string(header))
end

Then /^I should receive an HTTP (\d+) response with an empty body$/ do |status_code|
  steps %Q{
    Then I should receive an HTTP #{status_code} response with a body matching ""
  }
end

Then /^I should receive an HTTP (\d+) response with a body matching "([^\"]*)"$/ do |status_code, http_body|
  @httpclient.should have_response_with_code_and_body(status_code.to_i, http_body)
end

Then /^I should receive an HTTP (\d+) response with a body containing:$/ do |status_code, http_body|
  @httpclient.should have_response_with_code_and_body(status_code.to_i, http_body)
end

Then /^I should receive an HTTP (\d+) response$/ do |status_code|
  @httpclient.should have_response_with_code(status_code.to_i)
end

Then /^I should receive an HTTP (\d+) response with the value "([^\"]*)" for the header "([^\"]*)"$/ do |status_code, header_value, header_key|
  @httpclient.should have_response_with_code_and_header(status_code.to_i, header_key, header_value)
end

Then /^I should receive an HTTP (\d+) response with the JSON value "([^\"]*)" for the key path "([^\"]*)"$/ do |status, json_value, key_path|
  json = JSON.parse(@httpclient.last_response.to_s)
  json.value_for_key_path(key_path).should == json_value
end

Then /^I should receive an HTTP (\d+) response with the Plist value "([^\"]*)" for the key path "([^\"]*)"$/ do |status, json_value, key_path|
  plist = Plist.parse_xml(@httpclient.last_response.to_s)
  plist.value_for_key_path(key_path).should == json_value
end

# For debugging. You'll need to gem install bcat
Then /^show me the response$/ do
  IO.popen("bcat", "w") do |bcat|
    bcat.puts @httpclient.last_response
  end
end

