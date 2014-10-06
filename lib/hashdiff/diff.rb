module HashDiff

  # Best diff two objects, which tries to generate the smallest change set using different similarity values.
  #
  # HashDiff.best_diff is useful in case of comparing two objects which include similar hashes in arrays.
  #
  # @param [Array, Hash] obj1
  # @param [Array, Hash] obj2
  # @param [Hash] options the options to use when comparing
  #   * :strict (Boolean) [true] whether numeric values will be compared on type as well as value.  Set to false to allow comparing Fixnum, Float, BigDecimal to each other
  #   * :delimiter (String) ['.'] the delimiter used when returning nested key references
  #   * :numeric_tolerance (Numeric) [0] should be a positive numeric value.  Value by which numeric differences must be greater than.  By default, numeric values are compared exactly; with the :tolerance option, the difference between numeric values must be greater than the given value.
  #   * :strip (Boolean) [false] whether or not to call #strip on strings before comparing
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
    options[:comparison] = block if block_given?

    opts = { :similarity => 0.3 }.merge!(options)
    diffs_1 = diff(obj1, obj2, opts)
    count_1 = count_diff diffs_1

    opts = { :similarity => 0.5 }.merge!(options)
    diffs_2 = diff(obj1, obj2, opts)
    count_2 = count_diff diffs_2

    opts = { :similarity => 0.8 }.merge!(options)
    diffs_3 = diff(obj1, obj2, opts)
    count_3 = count_diff diffs_3

    count, diffs = count_1 < count_2 ? [count_1, diffs_1] : [count_2, diffs_2]
    diffs = count < count_3 ? diffs : diffs_3
  end

  # Compute the diff of two hashes or arrays
  #
  # @param [Array, Hash] obj1
  # @param [Array, Hash] obj2
  # @param [Hash] options the options to use when comparing
  #   * :strict (Boolean) [true] whether numeric values will be compared on type as well as value.  Set to false to allow comparing Fixnum, Float, BigDecimal to each other
  #   * :similarity (Numeric) [0.8] should be between (0, 1]. Meaningful if there are similar hashes in arrays. See {best_diff}.
  #   * :delimiter (String) ['.'] the delimiter used when returning nested key references
  #   * :numeric_tolerance (Numeric) [0] should be a positive numeric value.  Value by which numeric differences must be greater than.  By default, numeric values are compared exactly; with the :tolerance option, the difference between numeric values must be greater than the given value.
  #   * :strip (Boolean) [false] whether or not to call #strip on strings before comparing
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
    opts = {
      :prefix      =>   '',
      :similarity  =>   0.8,
      :delimiter   =>   '.',
      :strict      =>   true,
      :strip       =>   false,
      :numeric_tolerance => 0
    }.merge!(options)

    opts[:comparison] = block if block_given?

    # prefer to compare with provided block
    result = custom_compare(opts[:comparison], opts[:prefix], obj1, obj2)
    return result if result

    if obj1.nil? and obj2.nil?
      return []
    end

    if obj1.nil?
      return [['~', opts[:prefix], nil, obj2]]
    end

    if obj2.nil?
      return [['~', opts[:prefix], obj1, nil]]
    end

    unless comparable?(obj1, obj2, opts[:strict])
      return [['~', opts[:prefix], obj1, obj2]]
    end

    result = []
    if obj1.is_a?(Array)
      changeset = diff_array(obj1, obj2, opts) do |lcs|
        # use a's index for similarity
        lcs.each do |pair|
          result.concat(diff(obj1[pair[0]], obj2[pair[1]], opts.merge(:prefix => "#{opts[:prefix]}[#{pair[0]}]")))
        end
      end

      changeset.each do |change|
        if change[0] == '-'
          result << ['-', "#{opts[:prefix]}[#{change[1]}]", change[2]]
        elsif change[0] == '+'
          result << ['+', "#{opts[:prefix]}[#{change[1]}]", change[2]]
        end
      end
    elsif obj1.is_a?(Hash)
      if opts[:prefix].empty?
        prefix = ""
      else
        prefix = "#{opts[:prefix]}#{opts[:delimiter]}"
      end

      deleted_keys = obj1.keys - obj2.keys
      common_keys = obj1.keys & obj2.keys
      added_keys = obj2.keys - obj1.keys

      # add deleted properties
      deleted_keys.sort.each do |k|
        custom_result = custom_compare(opts[:comparison], "#{prefix}#{k}", obj1[k], nil)

        if custom_result
          result.concat(custom_result)
        else
          result << ['-', "#{prefix}#{k}", obj1[k]]
        end
      end

      # recursive comparison for common keys
      common_keys.sort.each {|k| result.concat(diff(obj1[k], obj2[k], opts.merge(:prefix => "#{prefix}#{k}"))) }

      # added properties
      added_keys.sort.each do |k|
        unless obj1.key?(k)
          custom_result = custom_compare(opts[:comparison], "#{prefix}#{k}", nil, obj2[k])

          if custom_result
            result.concat(custom_result)
          else
            result << ['+', "#{prefix}#{k}", obj2[k]]
          end
        end
      end
    else
      return [] if compare_values(obj1, obj2, opts)
      return [['~', opts[:prefix], obj1, obj2]]
    end

    result
  end

  # @private
  #
  # diff array using LCS algorithm
  def self.diff_array(a, b, options = {})
    opts = {
      :prefix      =>   '',
      :similarity  =>   0.8,
      :delimiter   =>   '.'
    }.merge!(options)

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

    links = lcs(a, b, opts)

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
