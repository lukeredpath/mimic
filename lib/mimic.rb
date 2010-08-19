require 'mimic/fake_host'
require 'singleton'
require 'rack'
require 'ghost'
require 'logger'

module Mimic
  MIMIC_DEFAULT_PORT = 11988
  
  def self.mimic(options = {}, &block)
    options = {:hostname => 'localhost', :port => MIMIC_DEFAULT_PORT}.merge(options)
    
    FakeHost.new(options[:hostname]).tap do |host|
      host.instance_eval(&block) if block_given?
      Server.instance.serve(host, options[:port])
    end
  end
  
  def self.cleanup!
    Mimic::Server.instance.shutdown
  end

  class Server
    include Singleton

    def logger
      @logger ||= Logger.new(StringIO.new)
    end

    def serve(host_app, port)
      @thread = Thread.fork do
        Rack::Handler::WEBrick.run(host_app, 
          :Port      => port, 
          :Logger    => logger, 
          :AccessLog => logger
          
        ) { |server| @server = server }
      end
    end
    
    def shutdown
      if @thread
        Thread.kill(@thread) 
        @server.shutdown
      end
    end
  end
end
