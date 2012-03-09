require 'mimic/fake_host'
require 'singleton'
require 'rack'
require 'logger'

module Mimic
  MIMIC_DEFAULT_PORT = 11988

  MIMIC_DEFAULT_OPTIONS = {
    :hostname => 'localhost',
    :port => MIMIC_DEFAULT_PORT,
    :remote_configuration_path => nil,
    :fork => true,
    :log => nil
  }

  def self.mimic(options = {}, &block)
    options = MIMIC_DEFAULT_OPTIONS.merge(options)

    host = FakeHost.new(options).tap do |host|
      host.instance_eval(&block) if block_given?
      Server.instance.serve(host, options)
    end
    add_host(host)
  end

  def self.cleanup!
    Mimic::Server.instance.shutdown
  end
  
  def self.reset_all!
    @hosts.each { |h| h.clear }
  end
  
  private
  
  def self.add_host(host)
    host.tap { |h| (@hosts ||= []) << h }
  end

  class Server
    include Singleton

    def logger
      @logger ||= Logger.new(StringIO.new)
    end

    def serve(app, options)
      if options[:fork]
        @thread = Thread.fork do
          start_service(app, options)
        end

        wait_for_service(app.hostname, options[:port])

      else
        start_service(app, options)
      end
    end

    def start_service(app, options)
      Rack::Handler::WEBrick.run(app.url_map, {
        :Port       => options[:port],
        :Logger     => logger,
        :AccessLog  => logger,

      }) do |server|
        @server = server

        @previous_int_handler = trap('INT') do
          begin
            # support case of default command String names
            @previous_int_handler.call if @previous_int_handler and @previous_int_handler.respond_to?("call")
          rescue StandardError => e
            puts "Error occurred invoking previous interrupt handler: #{e.class} #{e.to_s}"
          end
          @server.shutdown
        end
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
