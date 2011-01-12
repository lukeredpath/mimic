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
    
    %w{get post put delete head}.each do |verb|
      post "/#{verb}" do
        data = JSON.parse(request.body.string)
        host.send(verb, data['path']).returning(data['body'] || '', data['code'] || 200, data['headers'] || {})
        [201, {}, data.inspect]
      end
    end
  end
end
