require 'sinatra/base'
require 'mimic/api'

module Mimic
  class FakeHost
    attr_reader :hostname, :url_map
    attr_accessor :log
    
    def initialize(options = {})
      @hostname = options[:hostname]
      @remote_configuration_path = options[:remote_configuration_path]
      @log = options[:log]
      @imports = []
      clear      
      build_url_map!
    end
    
    def received_requests
      @stubs.select { |s| s.received }
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
    
    def import(path)
      if File.exists?(path)
        @imports << path unless @imports.include?(path)
        instance_eval(File.read(path))
      else
        raise "Could not locate file for stub import: #{path}"
      end
    end
    
    def call(env)
      @stubs.each(&:build)
      @app.call(env)
    end
    
    def clear
      @stubs = []
      @app = Sinatra.new
      @app.use Rack::CommonLogger, self.log if self.log
      @app.not_found do
        [404, {}, ""]
      end
      @app.helpers do
        include Helpers
      end
      @imports.each { |file| import(file) }
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
    
    module Helpers
      def echo_request!(format)
        RequestEcho.new(request).response_as(format)
      end
    end
    
    class RequestEcho
      def initialize(request)
        @request = request
      end
      
      def response_as(format)
        content_type = case format
        when :json, :plist
          "application/#{format.to_s.downcase}"
        else
          "text/plain"
        end
        [200, {"Content-Type" => content_type}, to_s(format)]
      end
      
      def to_s(format)
        case format
          when :json
            to_hash.to_json
          when :plist
            to_hash.to_plist
          when :text
            to_hash.inspect
        end
      end
      
      def to_hash
        {"echo" => {
          "params" => @request.params,
          "env"    => env_without_rack_and_async_env,
          "body"   => @request.body.read
        }}
      end
      
      private
      
      def env_without_rack_and_async_env
        Hash[*@request.env.select { |key, value| key !~ /^(rack|async)/i }.flatten]
      end
    end
    
    class StubbedRequest
      attr_accessor :received
      
      def initialize(app, method, path)
        @method, @path = method, path
        @code = 200
        @headers = {}
        @params = {}
        @body = ""
        @app = app
        @received = false
      end
      
      def to_hash
        token = "#{@method} #{@path}"
        Digest::MD5.hexdigest(token)
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
        if @echo_request_format
          @body = RequestEcho.new(request).to_s(@echo_request_format)
        end
        
        matches?(request) ? matched_response : unmatched_response
      end
      
      def build
        stub = self

        @app.send(@method.downcase, @path) do
          stub.received = true
          stub.response_for_request(request)
        end
      end
    end
  end
end
