require 'rest_client'

class HttpClient
  attr_reader :last_response
  
  def self.use_proxy(proxy)
    RestClient.proxy = proxy
  end
  
  def initialize
    @last_response = nil
  end
  
  def perform_request(url, method, payload = nil, options={})
    RestClient.send(method.downcase, url, options) do |response, request|
      @last_response = response
    end
  end
  
  def perform_request_with_payload(url, method, payload, options={})
    RestClient.send(method.downcase, url, payload, options) do |response, request|
      @last_response = response
    end
  end
  
  def has_response_with_code_and_body?(status_code, response_body)
    if @last_response
      return @last_response.code.to_i == status_code && @last_response.to_s == response_body
    end
  end
  
  def has_response_with_code?(status_code)
    if @last_response
      @last_response.code.to_i == status_code
    end
  end
end
