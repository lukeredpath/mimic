require 'json'
require 'plist'

module Mimic
  class API < Sinatra::Base
    class << self
      attr_accessor :host
    end
    
    def host
      self.class.host
    end
    
    %w{get post put delete head}.each do |verb|
      post "/#{verb}" do
        api_request = APIRequest.from_request(request, verb)
        api_request.setup_stubs_on(host)
        [201, {"Content-Type" => api_request.request_content_type}, api_request.response]
      end
    end
    
    post "/multi" do
      api_request = APIRequest.from_request(request)
      api_request.setup_stubs_on(host)
      [201, {"Content-Type" => api_request.request_content_type}, api_request.response]
    end
    
    post "/clear" do
      response_body = self.host.inspect
      self.host.clear
      [200, {}, "Cleared stubs: #{response_body}"]
    end
    
    get "/ping" do
      [200, {}, "OK"]
    end
    
    get "/debug" do
      [200, {}, self.host.inspect]
    end
    
    get "/requests" do
      [200, {"Content-Type" => "application/json"}, {"requests" => host.received_requests.map(&:to_hash)}.to_json]
    end
    
    private
    
    class APIRequest
      attr_reader :request_content_type
      
      def initialize(data, method = nil, request_content_type = '')
        @data = data
        @method = (method || "GET")
        @stubs = []
        @request_content_type = request_content_type
      end
      
      def to_s
        @data.inspect
      end
      
      def response
        response = {"stubs" => @stubs.map(&:to_hash)}
        
        case request_content_type
        when /json/
          response.to_json
        when /plist/
          response.to_plist
        else
          response.to_json
        end
      end
      
      def self.from_request(request, method = nil)
        case request.content_type
          when /json/
            data = JSON.parse(request.body.string)
          when /plist/
            data = Plist.parse_xml(request.body.string)
          else
            data = JSON.parse(request.body.string)
        end
        new(data, method, request.content_type)
      end
      
      def setup_stubs_on(host)
        (@data["stubs"] || [@data]).each do |stub_data|
          @stubs << Stub.new(stub_data, stub_data['method'] || @method).on(host)
        end
      end
      
      class Stub
        def initialize(data, method = nil)
          @data = data
          @method = method
        end
        
        def on(host)
          host.send(@method.downcase.to_sym, path).returning(body, code, headers).tap do |stub|
            stub.with_query_parameters(params)
            stub.echo_request!(echo_format)
          end
        end
        
        def echo_format
          @data['echo'].to_sym rescue nil
        end

        def path
          @data['path'] || '/'
        end

        def body
          @data['body'] || ''
        end

        def code
          @data['code'] || 200
        end

        def headers
          @data['headers'] || {}
        end
        
        def params
          @data['params'] || {}
        end
      end
    end
  end
end
