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
    :remote_configuration_path => nil,
    :fork => true
  }

  def self.mimic(options = {}, &block)
    options = MIMIC_DEFAULT_OPTIONS.merge(options)

    FakeHost.new(options[:hostname], options[:remote_configuration_path]).tap do |host|
      host.instance_eval(&block) if block_given?
      Server.instance.serve(host, options[:port], options[:fork])
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

    def serve(host_app, port, should_fork)
      if should_fork
        @thread = Thread.fork do
          start_service(host_app, port)
        end

        wait_for_service(host_app.hostname, port)
        
      else
        start_service(host_app, port)
      end
    end

    def start_service(host_app, port)
      Rack::Handler::WEBrick.run(host_app.url_map, {
        :Port       => port,
        :Logger     => logger,
        :AccessLog  => logger,

      }) do |server|
        @server = server

        trap("TERM") { @server.shutdown }
        trap("INT")  { @server.shutdown }
      end
    end

    def shutdown
      Thread.kill(@thread) if @thread
      @server.shutdown if @server
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
