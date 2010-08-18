Given /^I have a mimic specification with:$/ do |string|
  MimicRunner.new.evaluate(string)
end
