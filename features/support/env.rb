$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. .. lib]))

Before do
  if test_proxy = ENV["MIMIC_TEST_PROXY"]
    HttpClient.use_proxy(test_proxy)
  end  
end
