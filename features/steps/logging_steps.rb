Then /^I should see "([^"]*)" written to STDOUT$/ do |output|
  expect(TEST_STDOUT.tap { |io| io.rewind }.read).to include(output)
end
