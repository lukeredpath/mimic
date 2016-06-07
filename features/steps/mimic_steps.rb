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
  
  # wait for Mimic to shutdown
  start_time, timeout = Time.now, 3

  until !Mimic::Server.instance.listening?('localhost', 11988)
    if Time.now > (start_time + timeout)
      raise "Socket did not close within #{timeout} seconds"
    end
  end
end
