# What is Mimic?
Mimic is a testing tool that lets you set create a fake stand-in for an external web service to be used when writing integration/end-to-end tests for applications or libraries that access these services.

Note: this is still very early in its development; don't let the existence of this README fool you into thinking its ready for prime-time!

## Why not stub?
There are already some good tools, like [FakeWeb](http://fakeweb.rubyforge.org/) which let you stub requests at a low-level which is fine for unit and functional tests but when exercising our code through integration or end-to-end tests we want to exercise as much of the stack as possible.

Mimic aims to make it possible to test your networking code without actually hitting the real services by starting up a real web server and responding to HTTP requests. This lets you test your application against canned responses in an as-close-to-the-real-thing-as-possible way.

Also, because Mimic responds to real HTTP requests, it can be used when testing non-Ruby applications too.

## Examples

Registering to a single request stub:

    Mimic.mimic.get("/some/path").returning("hello world")
    
And the result, using RestClient:
  
    $ RestClient.get("http://www.example.com:11988/some/path") # => 200 | hello world
  
Registering multiple request stubs; note that you can stub the same path with different HTTP methods separately.

    Mimic.mimic do
      get("/some/path").returning("Hello World", 200)
      get("/some/other/path").returning("Redirecting...", 301, {"Location" => "somewhere else"})
      post("/some/path").returning("Created!", 201)
    end
    
You can even use Rack middlewares, e.g. to handle common testing scenarios such as authentication:

    Mimic.mimic do
      use Rack::Auth::Basic do |user, pass|
        user == 'theuser' and pass == 'thepass'
      end
      
      get("/some/path")
    end
    
Finally, because Mimic is built on top of Sinatra for the core request handling, you can create your stubbed requests like you would in any Sinatra app:

    Mimic.mimic do
      get "/some/path" do
        [200, {}, "hello world"]
      end
    end

## Contributors

* [James Fairbairn](http://github.com/jfairbairn)

## License

As usual, the code is released under the MIT license which is included in the repository.

