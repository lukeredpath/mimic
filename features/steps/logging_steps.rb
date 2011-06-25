Then /^I should see "([^"]*)" written to STDOUT$/ do |output|
  TEST_STDOUT.tap { |io| io.rewind }.read.should include(output)
end
