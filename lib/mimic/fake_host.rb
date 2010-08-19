require 'sinatra/base'

module Mimic
  class FakeHost
    attr_reader :hostname
    
    def initialize(hostname)
      @hostname = hostname
      @stubs = []
      @app = Class.new(Sinatra::Base)
      
      @app.not_found do
        [404, {}, ""]
      end
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
    
    private
    
    def request(method, path, &block)
      if block_given?
        @app.send(method.downcase, path, &block)
      else
        @stubs << StubbedRequest.new(@app, method, path)
        @stubs.last
      end
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
