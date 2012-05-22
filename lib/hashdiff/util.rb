module HashDiff

  # return an array of added properties
  # e.g. [[ '+', 'a.b', 45 ], [ '-', 'a.c', 5 ]]
  def self.changed(obj, sign, prefix = "")
    return [[sign, prefix, obj]] unless obj

    results = []
    if obj.is_a?(Array)
      if sign == '+'
        # add from the begining
        results << [sign, prefix, []]
        obj.each_index do |index|
          results.concat(changed(obj[index], sign, "#{prefix}[#{index}]"))
        end
      elsif sign == '-'
        # delete from the end
        obj.each_index do |index|
          i = obj.size - index - 1
          results.concat(changed(obj[i], sign, "#{prefix}[#{i}]"))
        end
        results << [sign, prefix, []]
      end
    elsif obj.is_a?(Hash)
      results << [sign, prefix, {}] if sign == '+'
      prefix_t = prefix.empty? ? "" : "#{prefix}."
      obj.each do |k, v|
        results.concat(changed(v, sign, "#{prefix_t}#{k}"))
      end
      results << [sign, prefix, {}] if sign == '-'
    else
      return [[sign, prefix, obj]]
    end

    results
  end

  # judge whether two objects are similar
  def self.similiar?(a, b, similarity = 0.8)
    count_a = count_nodes(a)
    count_b = count_nodes(b)
    count_diff = diff(a, b, "", similarity).count

    if count_a + count_b == 0
      return true
    else
      (1 - count_diff.to_f/(count_a + count_b).to_f) >= similarity
    end
  end

  # count total nodes for an object
  def self.count_nodes(obj)
    return 0 unless obj

    count = 0
    if obj.is_a?(Array)
      count = obj.size
      obj.each {|e| count += count_nodes(e) }
    elsif obj.is_a?(Hash)
      count = obj.size
      obj.each {|k, v| count += count_nodes(v) }
    else
      return 1
    end

    count
  end

  # decode property path into an array
  #
  # e.g. "a.b[3].c" => ['a', 'b', 3, 'c']
  def self.decode_property_path(path)
    parts = path.split('.').collect do |part|
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

  # get the node of hash by given path parts
  def self.node(hash, parts)
    temp = hash
    parts.each do |part|
      temp = temp[part]
    end
    temp
  end

end
