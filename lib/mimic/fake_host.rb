module Mimic
  class FakeHost
    attr_reader :hostname
    
    def initialize(hostname, unhandled_response_strategy = NotFoundResponseStrategy.new)
      @hostname = hostname
      @stubs = {}
      @unhandled_response_strategy = unhandled_response_strategy
    end
    
    def get(path)
      request("GET", path)
    end
    
    def post(path)
      request("POST", path)
    end
    
    def put(path)
      request("PUT", path)
    end
    
    def delete(path)
      request("DELETE", path)
    end
    
    def head(path)
      request("HEAD", path)
    end
    
    def call(env)
      handler_for_call(env).call(env)
    end
    
    def terminate
      Mimic.terminate(@hostname)
    end
    
    private
    
    def request(method, path)
      @stubs[path] = StubbedRequest.new(method, path)
    end
    
    def handler_for_call(env)
      (@stubs[env['PATH_INFO']] || @unhandled_response_strategy)
    end
    
    class StubbedRequest
      def initialize(method, path)
        @method, @path = method, path
        @code = 200
        @headers = {}
        @body = ""
      end
      
      def returning(body, code = 200, headers = {})
        tap do
          @body = body
          @code = code
          @headers = headers
        end
      end
      
      def call(env)
        [@code, @headers, @body]
      end
    end
    
    class NotFoundResponseStrategy
      def call(env)
        [404, {}, ""]
      end
    end
  end
end
