module HashDiff

  # @private
  #
  # judge whether two objects are similar
  def self.similar?(a, b, options = {})
    opts = { :similarity => 0.8 }.merge(options)

    count_a = count_nodes(a)
    count_b = count_nodes(b)
    diffs = count_diff diff(a, b, opts)

    if count_a + count_b == 0
      return true
    else
      (1 - diffs.to_f/(count_a + count_b).to_f) >= opts[:similarity]
    end
  end

  # @private
  #
  # count node differences
  def self.count_diff(diffs)
    diffs.inject(0) do |sum, item|
      old_change_count = count_nodes(item[2])
      new_change_count = count_nodes(item[3])
      sum += (old_change_count + new_change_count)
    end
  end

  # @private
  #
  # count total nodes for an object
  def self.count_nodes(obj)
    return 0 unless obj

    count = 0
    if obj.is_a?(Array)
      obj.each {|e| count += count_nodes(e) }
    elsif obj.is_a?(Hash)
      obj.each {|k, v| count += count_nodes(v) }
    else
      return 1
    end

    count
  end

  # @private
  #
  # decode property path into an array
  # @param [String] path Property-string
  # @param [String] delimiter Property-string delimiter
  #
  # e.g. "a.b[3].c" => ['a', 'b', 3, 'c']
  def self.decode_property_path(path, delimiter='.')
    parts = path.split(delimiter).collect do |part|
      if part =~ /^(\w*)\[(\d+)\]$/
        if $1.size > 0
          [$1, $2.to_i]
        else
          $2.to_i
        end
      else
        part
      end
    end

    parts.flatten
  end

  # @private
  #
  # get the node of hash by given path parts
  def self.node(hash, parts)
    temp = hash
    parts.each do |part|
      temp = temp[part]
    end
    temp
  end

  # @private
  #
  # check for equality or "closeness" within given tolerance
  def self.compare_within_tolerance(obj1, obj2, tolerance = nil)
    if tolerance && obj1.respond_to?(:-)
      (obj1 - obj2).abs <= tolerance
    else
      obj1 == obj2
    end
  end
end
