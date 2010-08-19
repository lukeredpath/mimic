# What is Mimic?
Mimic is a testing tool that lets you set create a fake stand-in for an external web service to be used when writing integration/end-to-end tests for applications or libraries that access these services.

Note: this is still very early in its development; don't let the existence of this README fool you into thinking its ready for prime-time!

## Why not stub?
There are already some good tools, like [FakeWeb](http://fakeweb.rubyforge.org/) which let you stub requests at a low-level which is fine for unit and functional tests but when exercising our code through integration or end-to-end tests we want to exercise as much of the stack as possible.

Mimic aims to make it possible to test your networking code without actually hitting the real services by starting up a real web server and responding to HTTP requests. This lets you test your application against canned responses in an as-close-to-the-real-thing-as-possible way.

Also, because Mimic responds to real HTTP requests, it can be used when testing non-Ruby applications too.

## How does it work?

Mimic's API is designed to be simple yet expressive. You simply register the host that you want to fake and then register any number of requests and responses. Mimic will then start an HTTP server (using Rack and WEBRick) on the specified port and add an entry to your hosts file (OSX and Linux only) for that host.

## Examples

Registering to a single request stub:

    Mimic.mimic("www.example.com", 10090).get("/some/path").returning("hello world")
    
And the result, using RestClient:
  
    $ RestClient.get("http://www.example.com:10090/some/path") # => 200 | hello world
  
Registering multiple request stubs; note that you can stub the same path with different HTTP methods separately.

    Mimic.mimic("www.example.com", 10090) do
      get("/some/path").returning("Hello World", 200)
      get("/some/other/path").returning("Redirecting...", 301, {"Location" => "somewhere else"})
      post("/some/path").returning("Created!", 201)
    end
    
## Caveats

* Because the server is not started on port 80, you need a way of configuring your application under test to use a different port at runtime.

* Mimic uses the Ghost gem to modify the hosts file and is therefore dependent on support for this gem. In addition, Ghost currently requires sudo privileges to run which means entering your password. I'm happy to hear any suggestions for working around this.

## License

As usual, the code is released under the MIT license which is included in the repository.
