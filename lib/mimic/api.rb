require 'json'

module Mimic
  class API < Sinatra::Base
    class << self
      attr_accessor :host
    end
    
    def host
      self.class.host
    end
    
    before { content_type(:json) }
    
    post "/get" do
      data = JSON.parse(request.body.string)
      host.get(data['path'])
      [201, {}, host.inspect]
    end
  end
end
