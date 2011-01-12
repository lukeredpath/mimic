require 'sinatra/base'
require 'mimic/api'

module Mimic
  class FakeHost
    attr_reader :hostname, :url_map
    
    def initialize(hostname, remote_configuration_path = nil)
      @hostname = hostname
      @stubs = []
      @app = Class.new(Sinatra::Base)
      @remote_configuration_path = remote_configuration_path

      @app.not_found do
        [404, {}, ""]
      end
      
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
    
    def call(env)
      @stubs.each(&:build)
      @app.call(env)
    end
    
    def method_missing(method, *args, &block)
      @app.send(method, *args, &block)
    end
    
    def evaluate_file(path)
      if File.exists?(path)
        instance_eval(File.read(path))
      end
    end
    
    private
    
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
      
      def build
        response = [@code, @headers, @body]
        @app.send(@method.downcase, @path) { response }
      end
    end
  end
end
