module HashDiff

  # Best diff two objects, which tries to generate the smallest change set using different similarity values.
  #
  # HashDiff.best_diff is useful in case of comparing two objects which include similar hashes in arrays.
  #
  # @param [Array, Hash] obj1
  # @param [Array, Hash] obj2
  # @param [Hash] options the options to use when comparing
  #   * :strict (Boolean) [true] whether numeric values will be compared on type as well as value.  Set to false to allow comparing Integer, Float, BigDecimal to each other
  #   * :delimiter (String) ['.'] the delimiter used when returning nested key references, or false to use array paths
  #   * :numeric_tolerance (Numeric) [0] should be a positive numeric value.  Value by which numeric differences must be greater than.  By default, numeric values are compared exactly; with the :tolerance option, the difference between numeric values must be greater than the given value.
  #   * :strip (Boolean) [false] whether or not to call #strip on strings before comparing
  #   * :stringify_keys [true] whether or not to convert object keys to strings
  #
  # @yield [path, value1, value2] Optional block is used to compare each value, instead of default #==. If the block returns value other than true of false, then other specified comparison options will be used to do the comparison.
  #
  # @return [Array] an array of changes.
  #   e.g. [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  #
  # @example
  #   a = {'x' => [{'a' => 1, 'c' => 3, 'e' => 5}, {'y' => 3}]}
  #   b = {'x' => [{'a' => 1, 'b' => 2, 'e' => 5}] }
  #   diff = HashDiff.best_diff(a, b)
  #   diff.should == [['-', 'x[0].c', 3], ['+', 'x[0].b', 2], ['-', 'x[1].y', 3], ['-', 'x[1]', {}]]
  #
  # @since 0.0.1
  def self.best_diff(obj1, obj2, options = {}, &block)
    options = { }.merge!(options)
    options[:comparison] = block if block_given?

    options[:similarity] = 0.3
    diffs_1 = diff(obj1, obj2, options)
    count_1 = count_diff diffs_1

    options[:similarity] = 0.5
    diffs_2 = diff(obj1, obj2, options)
    count_2 = count_diff diffs_2

    options[:similarity] = 0.8
    diffs_3 = diff(obj1, obj2, options)
    count_3 = count_diff diffs_3

    count, diffs = count_1 < count_2 ? [count_1, diffs_1] : [count_2, diffs_2]
    diffs = count < count_3 ? diffs : diffs_3
  end

  # Compute the diff of two hashes or arrays
  #
  # @param [Array, Hash] obj1
  # @param [Array, Hash] obj2
  # @param [Hash] options the options to use when comparing
  #   * :strict (Boolean) [true] whether numeric values will be compared on type as well as value.  Set to false to allow comparing Integer, Float, BigDecimal to each other
  #   * :similarity (Numeric) [0.8] should be between (0, 1]. Meaningful if there are similar hashes in arrays. See {best_diff}.
  #   * :delimiter (String) ['.'] the delimiter used when returning nested key references, or nil to use array paths
  #   * :numeric_tolerance (Numeric) [0] should be a positive numeric value.  Value by which numeric differences must be greater than.  By default, numeric values are compared exactly; with the :tolerance option, the difference between numeric values must be greater than the given value.
  #   * :strip (Boolean) [false] whether or not to call #strip on strings before comparing
  #   * :stringify_keys [true] whether or not to convert object keys to strings
  #
  # @yield [path, value1, value2] Optional block is used to compare each value, instead of default #==. If the block returns value other than true of false, then other specified comparison options will be used to do the comparison.
  #
  # @return [Array] an array of changes.
  #   e.g. [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  #
  # @example
  #   a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
  #   b = {"a" => 1, "b" => {}}
  #
  #   diff = HashDiff.diff(a, b)
  #   diff.should == [['-', 'b.b1', 1], ['-', 'b.b2', 2]]
  #
  # @since 0.0.1
  def self.diff(obj1, obj2, options = {}, &block)
    options = {
      :prefix      =>   [],
      :similarity  =>   0.8,
      :delimiter   =>   '.',
      :strict      =>   true,
      :strip       =>   false,
      :stringify_keys => true,
      :numeric_tolerance => 0
    }.merge!(options)

    options[:stringify_keys] = true if options[:delimiter]
    options[:comparison] = block if block_given?

    change_set = diff_internal(obj1, obj2, options)

    if options[:delimiter]
      change_set.each do |change|
        change[1] = encode_property_path(change[1], options[:delimiter])
      end
    else
      change_set
    end
  end

  # @private
  #
  # diff two variables

  def self.diff_internal(obj1, obj2, options)
    prefix = options[:prefix]

    # prefer to compare with provided block
    result = custom_compare(options, prefix, obj1, obj2)
    return result if result

    if obj1.nil? and obj2.nil?
      return []
    end

    if obj1.nil?
      return [['~', prefix, nil, obj2]]
    end

    if obj2.nil?
      return [['~', prefix, obj1, nil]]
    end

    unless comparable?(obj1, obj2, options[:strict])
      return [['~', prefix, obj1, obj2]]
    end

    if obj1.is_a?(Array)
      return diff_array(obj1, obj2, options) do |lcs|
        # use a's index for similarity
        lcs.flat_map do |pair|
          diff_internal(obj1[pair[0]], obj2[pair[1]], options.merge(:prefix => prefix + [pair[0]]))
        end
      end
    elsif obj1.is_a?(Hash)
      return diff_object(obj1, obj2, options)
    else
      return [] if compare_values(obj1, obj2, options)
      return [['~', prefix, obj1, obj2]]
    end
  end

  # @private
  #
  # diff object
  def self.diff_object(a, b, options)
    prefix = options[:prefix]
    change_set = []
    deleted_keys = a.keys - b.keys
    common_keys = a.keys & b.keys
    added_keys = b.keys - a.keys

    # add deleted properties
    deleted_keys.sort_by{|k,v| k.to_s }.each do |k|
      subpath = prefix + [options[:stringify_keys] ? "#{k}" : k]
      custom_result = custom_compare(options, subpath, a[k], nil)

      if custom_result
        change_set.concat(custom_result)
      else
        change_set << ['-', subpath, a[k]]
      end
    end

    # recursive comparison for common keys
    common_keys.sort_by{|k,v| k.to_s }.each do |k|
      subpath = prefix + [options[:stringify_keys] ? "#{k}" : k]
      change_set.concat(diff_internal(a[k], b[k], options.merge(:prefix => subpath)))
    end

    # added properties
    added_keys.sort_by{|k,v| k.to_s }.each do |k|
      unless a.key?(k)
        subpath = prefix + [options[:stringify_keys] ? "#{k}" : k]
        custom_result = custom_compare(options, subpath, nil, b[k])

        if custom_result
          change_set.concat(custom_result)
        else
          change_set << ['+', subpath, b[k]]
        end
      end
    end

    change_set
  end

  # @private
  #
  # diff array using LCS algorithm
  def self.diff_array(a, b, options = {})
    prefix = options[:prefix]
    change_set = []

    if a.size == 0 and b.size == 0
      return []
    elsif a.size == 0
      b.each_index do |index|
        change_set << ['+', prefix + [index], b[index]]
      end
      return change_set
    elsif b.size == 0
      a.each_index do |index|
        i = a.size - index - 1
        change_set << ['-', prefix + [i], a[i]]
      end
      return change_set
    end

    links = lcs(a, b, options)

    # yield common
    change_set.concat(yield links) if block_given?

    # padding the end
    links << [a.size, b.size]

    last_x = -1
    last_y = -1
    links.each do |pair|
      x, y = pair

      # remove from a, beginning from the end
      (x > last_x + 1) and (x - last_x - 2).downto(0).each do |i|
        change_set << ['-', prefix + [last_y + i + 1], a[i + last_x + 1]]
      end

      # add from b, beginning from the head
      (y > last_y + 1) and 0.upto(y - last_y - 2).each do |i|
        change_set << ['+', prefix + [last_y + i + 1], b[i + last_y + 1]]
      end

      # update flags
      last_x = x
      last_y = y
    end

    change_set
  end

end
