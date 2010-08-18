require 'mimic'

class MimicRunner
  def evaluate(code_string)
    instance_eval(code_string)
    sleep(0.5)
  end
end
