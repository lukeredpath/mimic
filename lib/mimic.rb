require 'mimic/fake_host'
require 'singleton'
require 'rack'
require 'logger'
require 'daemons'

module Mimic
  MIMIC_DEFAULT_PORT = 11988

  MIMIC_DEFAULT_OPTIONS = {
    :hostname => 'localhost', 
    :port => MIMIC_DEFAULT_PORT,
    :remote_configuration_path => nil
  }
  
  def self.mimic(options = {}, &block)
    options = MIMIC_DEFAULT_OPTIONS.merge(options)
    
    FakeHost.new(options[:hostname], options[:remote_configuration_path]).tap do |host|
      host.instance_eval(&block) if block_given?
      Server.instance.serve(host, options[:port])
    end
  end
  
  def self.daemonize(options = {}, daemon_options = {})
    @daemon = Daemons.run_proc('mimic', daemon_options) { mimic(options) }
  end
  
  def self.cleanup!
    Mimic::Server.instance.shutdown

    if @daemon
      @daemon.zap_all
      @daemon = nil
    end
  end

  class Server
    include Singleton

    def logger
      @logger ||= Logger.new(StringIO.new)
    end

    def serve(host_app, port)
      @thread = Thread.fork do
        Rack::Handler::WEBrick.run(host_app.url_map, 
          :Port      => port, 
          :Logger    => logger, 
          :AccessLog => logger
          
        ) { |server| @server = server }
      end
      
      wait_for_service(host_app.hostname, port)
    end
    
    def shutdown
      if @thread
        Thread.kill(@thread) 
        @server.shutdown
      end
    end
    
    # courtesy of http://is.gd/eoYho
    
    def listening?(host, port)
      begin
        socket = TCPSocket.new(host, port)
        socket.close unless socket.nil?
        true
      rescue Errno::ECONNREFUSED, SocketError,
        Errno::EBADF,           # Windows
        Errno::EADDRNOTAVAIL    # Windows
        false
      end
    end

    def wait_for_service(host, port, timeout = 5)
      start_time = Time.now

      until listening?(host, port)
        if timeout && (Time.now > (start_time + timeout))
          raise SocketError.new("Socket did not open within #{timeout} seconds")
        end
      end
    end
  end
end
