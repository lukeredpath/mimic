Given /^I have a mimic specification with:$/ do |string|
  MimicRunner.new.evaluate(string)
end

After do
  Mimic.cleanup!
end
