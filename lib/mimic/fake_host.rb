module Mimic
  class FakeHost
    attr_reader :hostname
    
    def initialize(hostname, unhandled_response_strategy = NotFoundResponseStrategy.new)
      @hostname = hostname
      @stubs = {}
      @unhandled_response_strategy = unhandled_response_strategy
      @middlewares = []
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
      inner_app = handler_for_call(env)
      outer_app = @middlewares.reverse.inject(inner_app) do |app, middleware|
        middleware.call(app)
      end
      outer_app.call(env)
    end
    
    def use(middleware_klass, *args, &block)
      @middlewares << lambda { |app| middleware_klass.new(app, *args, &block) }
    end
    
    def terminate
      Mimic.terminate(@hostname)
    end
    
    private
    
    def request(method, path)
      stubbed_request = StubbedRequest.new(method, path)
      @stubs[stubbed_request.key] = stubbed_request
    end
    
    def handler_for_call(env)
      (@stubs[request_key(env)] || @unhandled_response_strategy)
    end
    
    def request_key(env)
      request = Rack::Request.new(env)
      StubbedRequest.key(request.request_method, request.path)
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
      
      def key
        self.class.key(@method, @path)
      end
      
      def self.key(method, path)
        "#{method} #{path}"
      end
    end
    
    class NotFoundResponseStrategy
      def call(env)
        [404, {}, ""]
      end
    end
  end
end
