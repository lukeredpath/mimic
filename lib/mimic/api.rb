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
        [201, {}, api_request.to_s]
      end
    end
    
    post "/multi" do
      api_request = APIRequest.from_request(request)
      api_request.setup_stubs_on(host)
      [201, {}, api_request.to_s]
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
    
    private
    
    class APIRequest
      def initialize(data, method = nil)
        @data = data
        @method = (method || "GET")
      end
      
      def to_s
        @data.inspect
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
        new(data, method)
      end
      
      def setup_stubs_on(host)
        (@data["stubs"] || [@data]).each do |stub_data|
          Stub.new(stub_data, stub_data['method'] || @method).on(host)
        end
      end
      
      class Stub
        def initialize(data, method = nil)
          @data = data
          @method = method
        end
        
        def on(host)
          stub = host.send(@method.downcase.to_sym, path).returning(body, code, headers)
          stub.with_query_parameters(params)
          stub.echo_request!(echo_format)
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
