require 'spec_helper'

describe "Mimic::FakeHost" do
  before do
    @host = Mimic::FakeHost.new(:hostname => "www.example.com")
  end
  
  it "should handle stubbed requests" do
    @host.get("/some/path")
    expect(@host.call(request_for("/some/path"))).to match_rack_response(200, {}, "")
  end
  
  it "should handle stubbed requests that return a response" do
    @host.get("/some/path").returning("hello world")
    expect(@host.call(request_for("/some/path"))).to match_rack_response(200, {}, "hello world")
  end
  
  it "should handle stubbed requests that return a specific HTTP code" do
    @host.get("/some/path").returning("redirecting", 301)
    expect(@host.call(request_for("/some/path"))).to match_rack_response(301, {}, "redirecting")
  end
  
  it "should handle stubbed requests that return specific headers" do
    @host.get("/some/path").returning("redirecting", 301, {"Location" => "http://somewhereelse.com"})
    expect(@host.call(request_for("/some/path"))).to match_rack_response(301, {"Location" => "http://somewhereelse.com"}, "redirecting")
  end
  
  it "should not recognize requests if they have the incorrect HTTP method" do
    @host.get("/some/path")
    expect(@host.call(request_for("/some/path", :method => "POST"))).to match_rack_response(404, {}, "")
  end
  
  it "should not handle multiple requests to a path with different HTTP methods" do
    @host.get("/some/path").returning("GET Request", 200)
    @host.post("/some/path").returning("POST Request", 201)
    expect(@host.call(request_for("/some/path", :method => "GET"))).to match_rack_response(200, {}, "GET Request")
    expect(@host.call(request_for("/some/path", :method => "POST"))).to match_rack_response(201, {}, "POST Request")
  end
  
  it "should handle requests with behaviour specified in a block using the Sinatra API" do
    @host.get("/some/path") do
      content_type 'text/plain'
      'bobby'
    end
    expect(@host.call(request_for("/some/path", :method => "GET"))).to match_rack_response(200, {'Content-Type' => 'text/plain;charset=utf-8'}, 'bobby')
  end
  
  it "should allow stubs to be cleared" do
    @host.get("/some/path")
    expect(@host.call(request_for("/some/path"))).to match_rack_response(200, {}, "")
    @host.clear
    expect(@host.call(request_for("/some/path"))).to match_rack_response(404, {}, "")
  end
  
  it "should allow stubs to be imported from a file" do
    @host.import(File.join(File.dirname(__FILE__), *%w[fixtures import_stubs.mimic]))
    expect(@host.call(request_for("/imported/path"))).to match_rack_response(200, {}, "")
  end
  
  it "should not clear imported stubs" do
    @host.import(File.join(File.dirname(__FILE__), *%w[fixtures import_stubs.mimic]))
    @host.clear
    expect(@host.call(request_for("/imported/path"))).to match_rack_response(200, {}, "")
  end
  
  it "should raise if import file does not exist" do
    expect { 
      @host.import(File.join(File.dirname(__FILE__), *%w[fixtures doesnt_exist.mimic]))
    }.to raise_error(RuntimeError)
  end
  
  it "returns a StubbedRequest" do
    expect(@host.get("/some/path")).to be_kind_of(Mimic::FakeHost::StubbedRequest)
  end
  
  describe "StubbedRequest" do
    it "has a unique hash based on it's parameters" do
      host = Mimic::FakeHost::StubbedRequest.new(stub, "GET", "/path")
      expect(host.to_hash).to eq(Digest::MD5.hexdigest("GET /path"))
    end
    
    it "has the same hash as an equivalent request" do
      host_one = Mimic::FakeHost::StubbedRequest.new(stub, "GET", "/path")
      host_two = Mimic::FakeHost::StubbedRequest.new(stub, "GET", "/path")
      expect(host_one.to_hash).to eq(host_two.to_hash)
    end
  end
  
  private
  
  def request_for(path, options={})
    options = {:method => "GET"}.merge(options)
    { "PATH_INFO"      => path, 
      "REQUEST_METHOD" => options[:method],
      "rack.errors"    => StringIO.new,
      "rack.input"     => StringIO.new }
  end
  
  RSpec::Matchers.define :match_rack_response do |code, headers, body|
    match do |actual|
      (actual[0] == code) &&
      (headers.all? {|k, v| actual[1][k] == v }) &&
      (actual[2].include?(body))
    end
  end
end
