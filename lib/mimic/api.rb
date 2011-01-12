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
    
    before { content_type(:json) }
    
    %w{get post put delete head}.each do |verb|
      post "/#{verb}" do
        case request.content_type
          when /json/
            data = JSON.parse(request.body.string)
          when /plist/
            data = Plist.parse_xml(request.body.string)
          else
            data = JSON.parse(request.body.string)
        end
        host.send(verb, data['path']).returning(data['body'] || '', data['code'] || 200, data['headers'] || {})
        [201, {}, data.inspect]
      end
    end
  end
end
