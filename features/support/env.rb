$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. .. lib]))

Before do
  if test_proxy = ENV["MIMIC_TEST_PROXY"]
    puts "(Using proxy #{test_proxy})"
    HttpClient.use_proxy(test_proxy)
  end  
end
