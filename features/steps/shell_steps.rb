Given /^I execute the script:$/ do |script|
  eval(script)
end

TEMP_FILES = []

Given /^the file "([^\"]*)" exists with the contents:$/ do |file_path, string|
  File.open(file_path, "w") { |io| io.write(string) }
  TEMP_FILES << file_path
end

After do
  TEMP_FILES.each { |path| FileUtils.rm(path) }
end
