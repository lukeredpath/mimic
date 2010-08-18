module Mimic
  class FakeHost
    attr_reader :hostname
    
    def initialize(hostname)
      @hostname = hostname
    end
    
    def get(path)
      map("GET", path) { [200, {}, ""] }
    end
    
    def call(env)
      [200, {}, ""]
    end
    
    def terminate
      Mimic.terminate(@hostname)
    end
    
    private
    
    def map(method, path)
      
    end
  end
end
