require 'rest_client'

class HttpClient
  attr_reader :last_response
  
  def initialize
    @last_response = nil
  end
  
  def perform_request(url, method)
    @last_response = RestClient.send(method.downcase, url)
  end
end
