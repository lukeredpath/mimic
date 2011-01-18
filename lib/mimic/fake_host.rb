require 'sinatra/base'
require 'mimic/api'

module Mimic
  class FakeHost
    attr_reader :hostname, :url_map
    
    def initialize(hostname, remote_configuration_path = nil)
      @hostname = hostname
      @remote_configuration_path = remote_configuration_path
      @imports = []
      clear      
      build_url_map!
    end
    
    def get(path, &block)
      request("GET", path, &block)
    end
    
    def post(path, &block)
      request("POST", path, &block)
    end
    
    def put(path, &block)
      request("PUT", path, &block)
    end
    
    def delete(path, &block)
      request("DELETE", path, &block)
    end
    
    def head(path, &block)
      request("HEAD", path, &block)
    end
    
    def import(path, replay = false)
      if File.exists?(path)
        @imports << path unless replay
        instance_eval(File.read(path))
      end
    end
    
    def call(env)
      @stubs.each(&:build)
      @app.call(env)
    end
    
    def clear
      @stubs = []
      @app = Class.new(Sinatra::Base)
      @app.not_found do
        [404, {}, ""]
      end
      @imports.each { |file| import(file, true) }
    end
    
    def inspect
      @stubs.inspect
    end
    
    private
    
    def method_missing(method, *args, &block)
      @app.send(method, *args, &block)
    end
    
    def request(method, path, &block)
      if block_given?
        @app.send(method.downcase, path, &block)
      else
        @stubs << StubbedRequest.new(@app, method, path)
        @stubs.last
      end
    end
    
    def build_url_map!
      routes = {'/' => self}
      
      if @remote_configuration_path
        API.host = self
        routes[@remote_configuration_path] = API
      end

      @url_map = Rack::URLMap.new(routes)
    end
    
    class StubbedRequest
      def initialize(app, method, path)
        @method, @path = method, path
        @code = 200
        @headers = {}
        @params = {}
        @body = ""
        @app = app
      end
      
      def returning(body, code = 200, headers = {})
        tap do
          @body = body
          @code = code
          @headers = headers
        end
      end
      
      def with_query_parameters(params)
        tap do
          @params = params
        end
      end
      
      def echo_request!(format = :json)
        @echo_request_format = format
      end
      
      def matches?(request)
        if @params.any?
          request.params == @params
        else
          true
        end
      end
      
      def matched_response
        [@code, @headers, @body]
      end
      
      def unmatched_response
        [404, "", {}]
      end
      
      def response_for_request(request)
        extract_echo_from_request(request) if @echo_request_format
        matches?(request) ? matched_response : unmatched_response
      end
      
      def build
        stub = self
        @app.send(@method.downcase, @path) { stub.response_for_request(request) }
      end
      
      def extract_echo_from_request(request)
        echo = {"echo" => {
          "params" => request.params,
          "env"    => env_without_rack_env(request.env),
          "body"   => request.body.read
        }}        
        case @echo_request_format
        when :json
          @body = echo.to_json
        when :plist
          @body = echo.to_plist
        when :text
          @body = echo.inspect
        end
      end
      
      def env_without_rack_env(env)
        Hash[*env.select { |key, value| key !~ /^rack/i }.flatten]
      end
    end
  end
end
