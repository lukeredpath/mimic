class Hash
  def value_for_key_path(key_path_string)
    key_path_string.split(".").inject(self) do |result, key|
      result[key]
    end
  end
end
