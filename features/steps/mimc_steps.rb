Given /^I have a mimic specification with:$/ do |string|
  MimicRunner.new.evaluate(string)
end

Given /^that Mimic is running and accepting remote configuration on "([^\"]*)"$/ do |api_endpoint|
  Mimic.mimic(:port => 11988, :remote_configuration_path => api_endpoint, :wait_timeout => 10, :fork => true)
end

Given /^that Mimic is running and accepting remote configuration on "([^\"]*)" with the existing stubs:$/ do |api_endpoint, existing_stubs|
  Mimic.mimic(:port => 11988, :remote_configuration_path => api_endpoint, :wait_timeout => 10, :fork => true) do
    eval(existing_stubs)
  end
end

When /^I evaluate the code:$/ do |string|
  eval(string)
end

After do
  Mimic.cleanup!
end
