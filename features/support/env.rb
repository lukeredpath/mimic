$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. .. lib]))

TEST_STDOUT = StringIO.new

Before do
  if test_proxy = ENV["MIMIC_TEST_PROXY"]
    HttpClient.use_proxy(test_proxy)
  end
  
  $stdout = TEST_STDOUT
end

After do
  $stdout = STDOUT
end
