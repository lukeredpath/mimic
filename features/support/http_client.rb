require 'rest_client'

class HttpClient
  attr_reader :last_response
  
  def initialize
    @last_response = nil
  end
  
  def perform_request(url, method)
    @last_response = RestClient.send(method.downcase, url)
  end
  
  def has_response_with_code_and_body?(status_code, response_body)
    if @last_response
      return @last_response.code == status_code && @last_response.body == response_body
    end
  end
end
