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
        stubs_from_request(data).each do |x|
          host.send(verb, x['path']).returning(x['body'] || '', x['code'] || 200, x['headers'] || {})
        end
        [201, {}, data.inspect]
      end
      
      post "/multi" do
        case request.content_type
          when /json/
            data = JSON.parse(request.body.string)
          when /plist/
            data = Plist.parse_xml(request.body.string)
          else
            data = JSON.parse(request.body.string)
        end
        stubs_from_request(data).each do |x|
          host.send((x['method'] || "get").downcase, x['path']).returning(x['body'] || '', x['code'] || 200, x['headers'] || {})
        end
        [201, {}, data.inspect]
      end
    end
    
    private
    
    def stubs_from_request(data)
      data["stubs"] ? data["stubs"] : [data]
    end
  end
end
