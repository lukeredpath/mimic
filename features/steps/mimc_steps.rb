Given /^I have a mimic specification with:$/ do |string|
  MimicRunner.new.evaluate(string)
end

Given /^that Mimic is daemonized and accepting remote configuration on (.*)$/ do |api_endpoint|
  Mimic.daemonize({:port => 11988, :remote_configuration_path => api_endpoint}, :ARGV => ['run'])
end

After do
  Mimic.cleanup!
end
