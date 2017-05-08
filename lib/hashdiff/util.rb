class Object
  def count_nodes
    1
  end
end

class Array
  def count_nodes
    count = 0

    self.each do |e|
      if e
        count += e.count_nodes
      end
    end

    count
  end
end

class Hash
  def count_nodes
    return @hd_node_count unless @hd_node_count.nil?

    count = 0

    self.each do |k, v|
      if v
        count += v.count_nodes
      end
    end

    @hd_node_count = count
    count
  end
end

module HashDiff

  # @private
  #
  # judge whether two objects are similar
  def self.similar?(a, b, options = {})
    return compare_values(a, b, options) unless a.is_a?(Array) || a.is_a?(Hash) || b.is_a?(Array) || b.is_a?(Hash)
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
    obj.count_nodes
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
      if part =~ /^(.*)\[(\d+)\]$/
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
  def self.compare_values(obj1, obj2, options = {})
    if (options[:numeric_tolerance].is_a? Numeric) &&
        [obj1, obj2].all? { |v| v.is_a? Numeric }
      return (obj1 - obj2).abs <= options[:numeric_tolerance]
    end

    if options[:strip] == true
      obj1 = obj1.strip if obj1.respond_to?(:strip)
      obj2 = obj2.strip if obj2.respond_to?(:strip)
    end

    if options[:case_insensitive] == true
      obj1 = obj1.downcase if obj1.respond_to?(:downcase)
      obj2 = obj2.downcase if obj2.respond_to?(:downcase)
    end

    obj1 == obj2
  end

  # @private
  #
  # check if objects are comparable
  def self.comparable?(obj1, obj2, strict = true)
    [Array, Hash].each do |type|
      return true if obj1.is_a?(type) && obj2.is_a?(type)
    end
    return true if !strict && obj1.is_a?(Numeric) && obj2.is_a?(Numeric)
    obj1.is_a?(obj2.class) && obj2.is_a?(obj1.class)
  end

  # @private
  #
  # try custom comparison
  def self.custom_compare(method, key, obj1, obj2)
    if method
      res = method.call(key, obj1, obj2)

      # nil != false here
      if res == false
        return [['~', key, obj1, obj2]]
      elsif res == true
        return []
      end
    end
  end
end
