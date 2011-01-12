# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mimic}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luke Redpath"]
  s.date = %q{2011-01-12}
  s.email = %q{luke@lukeredpath.co.uk}
  s.extra_rdoc_files = ["README.md"]
  s.files = ["LICENSE", "Rakefile", "README.md", "spec", "lib/mimic", "lib/mimic/api.rb", "lib/mimic/fake_host.rb", "lib/mimic.rb"]
  s.homepage = %q{http://lukeredpath.co.uk}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{A Ruby gem for faking external web services for testing}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<daemons>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<daemons>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
