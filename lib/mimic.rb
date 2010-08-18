require 'mimic/fake_host'
require 'singleton'
require 'rack'
require 'ghost'
require 'logger'

module Mimic
  MIMIC_DEFAULT_PORT = 11988
  
  def self.mimic(hostname, port = MIMIC_DEFAULT_PORT)
    FakeHost.new(hostname).tap do |host|
      registry.register_host(host)
      Server.instance.serve(host, port)
    end
  end
  
  def self.cleanup!
    Mimic::Server.instance.shutdown
    registry.unregister_all_hosts
  end

  private
  
  def self.registry
    @registry ||= Registry.new
  end

  class Server
    include Singleton

    def logger
      @logger ||= Logger.new(StringIO.new)
    end

    def serve(host_app, port)
      webrick_logger = logger
      @pid = fork do
        Rack::Handler::WEBrick.run(host_app, 
          :Port      => port, 
          :Logger    => webrick_logger, 
          :AccessLog => webrick_logger
        )
      end
    end
    
    def shutdown
      return unless @pid
      Process.kill('ABRT', @pid)
      Process.wait
    end
  end
  
  class Registry
    def initialize
      @hosts = []
    end
    
    def register_host(host)
      @hosts << host
      Host.add(host.hostname)
    end
    
    def unregister_host(host)
      @hosts.delete(host)
      Host.delete(host.hostname)
    end
    
    def unregister_all_hosts
      @hosts.each { |host| unregister_host(host) }
    end
  end
end
