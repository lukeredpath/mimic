require 'spec_helper'

describe "Mimic::FakeHost" do
  before do
    @unhandled_response_strategy = mock("UnhandledResponseStrategy")
    @host = Mimic::FakeHost.new("www.example.com", @unhandled_response_strategy)
  end
  
  it "should handle stubbed requests" do
    @host.get("/some/path")
    @host.call(request_for("/some/path")).should return_rack_response(200, {}, "")
  end
  
  it "should handle stubbed requests that return a response" do
    @host.get("/some/path").returning("hello world")
    @host.call(request_for("/some/path")).should return_rack_response(200, {}, "hello world")
  end
  
  it "should handle stubbed requests that return a specific HTTP code" do
    @host.get("/some/path").returning("redirecting", 301)
    @host.call(request_for("/some/path")).should return_rack_response(301, {}, "redirecting")
  end
  
  it "should handle stubbed requests that return specific headers" do
    @host.get("/some/path").returning("redirecting", 301, {"Location" => "http://somewhereelse.com"})
    @host.call(request_for("/some/path")).should return_rack_response(301, {"Location" => "http://somewhereelse.com"}, "redirecting")
  end
  
  it "should delegate unhandled calls to its unhandled response strategy" do
    @host.get("/some/path")
    @unhandled_response_strategy.expects(:call).with(request_for("/some/other/path"))
    @host.call(request_for("/some/other/path"))
  end
  
  context "in its default configuration" do
    before do
      @host = Mimic::FakeHost.new("www.example.com")
    end
    
    it "should handle unstubbed requests with an empty 404 response" do
      @host.call({}).should return_rack_response(404, {}, "")
    end
  end
 
  private
  
  def request_for(path)
    {"PATH_INFO" => path}
  end
 
  def return_rack_response(code, headers, body)
    simple_matcher "return rack response" do |actual|
      actual == [code, headers, body]
    end
  end
end
