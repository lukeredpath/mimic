require 'mimic/fake_host'

module Mimic
  def self.mimic(host)
    FakeHost.new(host)
  end
end
