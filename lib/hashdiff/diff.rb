module HashDiff

  # try to make the best diff that generates the smallest change set
  def self.best_diff(obj1, obj2)
    diffs_1 = diff(obj1, obj2, "", 0.3)
    diffs_2 = diff(obj1, obj2, "", 0.5)
    diffs_3 = diff(obj1, obj2, "", 0.8)

    diffs = diffs_1.size < diffs_2.size ? diffs_1 : diffs_2
    diffs = diffs.size < diffs_3.size ? diffs : diffs_3
  end

  # compute the diff of two hashes, return an array of changes
  # e.g. [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  #
  # NOTE: diff will treat nil as [], {} or "" in comparison according to different context.
  # 
  def self.diff(obj1, obj2, prefix = "", similarity = 0.8)
    if obj1.nil? and obj2.nil?
      return []
    end

    if obj1.nil?
      return [['-', prefix, nil]] + changed(obj2, '+', prefix)
    end

    if obj2.nil?
      return changed(obj1, '-', prefix) + [['+', prefix, nil]]
    end

    if !(obj1.is_a?(Array) and obj2.is_a?(Array)) and !(obj1.is_a?(Hash) and obj2.is_a?(Hash)) and !(obj1.is_a?(obj2.class) or obj2.is_a?(obj1.class))
      return changed(obj1, '-', prefix) + changed(obj2, '+', prefix)
    end

    result = []
    if obj1.is_a?(Array)
      changeset = diff_array(obj1, obj2, similarity) do |lcs|
        # use a's index for similarity
        lcs.each do |pair|
          result.concat(diff(obj1[pair[0]], obj2[pair[1]], "#{prefix}[#{pair[0]}]", similarity))
        end
      end

      changeset.each do |change|
        if change[0] == '-'
          result.concat(changed(change[2], '-', "#{prefix}[#{change[1]}]"))
        elsif change[0] == '+'
          result.concat(changed(change[2], '+', "#{prefix}[#{change[1]}]"))
        end
      end
    elsif obj1.is_a?(Hash)
      prefix = prefix.empty? ? "" : "#{prefix}."

      deleted_keys = []
      common_keys = []

      obj1.each do |k, v|
        if obj2.key?(k)
          common_keys << k
        else
          deleted_keys << k
        end
      end

      # add deleted properties
      deleted_keys.each {|k| result.concat(changed(obj1[k], '-', "#{prefix}#{k}")) }

      # recursive comparison for common keys
      common_keys.each {|k| result.concat(diff(obj1[k], obj2[k], "#{prefix}#{k}", similarity)) }

      # added properties
      obj2.each do |k, v|
        unless obj1.key?(k)
          result.concat(changed(obj2[k], '+', "#{prefix}#{k}"))
        end
      end
    else
      return [] if obj1 == obj2
      return [['~', prefix, obj1, obj2]]
    end

    result
  end

  # diff array using LCS algorithm
  def self.diff_array(a, b, similarity = 0.8)
    change_set = []
    if a.size == 0 and b.size == 0
      return []
    elsif a.size == 0
      b.each_index do |index|
        change_set << ['+', index, b[index]]
      end
      return change_set
    elsif b.size == 0
      a.each_index do |index|
        i = a.size - index - 1
        change_set << ['-', i, a[i]]
      end
      return change_set
    end

    links = lcs(a, b, similarity)

    # yield common
    yield links if block_given?

    # padding the end
    links << [a.size, b.size]

    last_x = -1
    last_y = -1
    links.each do |pair|
      x, y = pair

      # remove from a, beginning from the end
      (x > last_x + 1) and (x - last_x - 2).downto(0).each do |i|
        change_set << ['-', last_y + i + 1, a[i + last_x + 1]]
      end

      # add from b, beginning from the head
      (y > last_y + 1) and 0.upto(y - last_y - 2).each do |i|
        change_set << ['+', last_y + i + 1, b[i + last_y + 1]]
      end

      # update flags
      last_x = x
      last_y = y
    end

    change_set
  end

end
