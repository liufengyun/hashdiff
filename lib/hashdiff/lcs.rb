# frozen_string_literal: true

module Hashdiff
  # @private
  #
  # caculate array difference using LCS algorithm
  # http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
  def self.lcs(arraya, arrayb, options = {})
    Lcs.call(arraya, arrayb, options)
  end

  # @private
  #
  # Finds the pairs [index in arraya, index in arrayb] of similar items that
  # make up the longest common subsequence of the two arrays.
  class Lcs
    def self.call(arraya, arrayb, options = {})
      return [] if arraya.empty? || arrayb.empty?

      new(arraya, arrayb, options).call
    end

    # The table costs O(n * m), so it only covers the items between the common
    # prefix and suffix. The result is the same as with a full table.
    def call
      pair_common_suffix
      start = common_prefix_length
      backtrack(build_table(start), start)
      backtrack_through_prefix
      pairs.reverse
    end

    private

    attr_reader :arraya, :arrayb, :options, :pairs
    # the items the backtrack is at, walking from the last ones to the first
    attr_accessor :a_index, :b_index

    def initialize(arraya, arrayb, options)
      @arraya = arraya
      @arrayb = arrayb
      @options = { similarity: 0.8 }.merge!(options)
      @options[:prefix] = Hashdiff.prefix_append_array_index(@options[:prefix], '*', @options)
      @pairs = []
      self.a_index = arraya.size - 1
      self.b_index = arrayb.size - 1
    end

    # The backtrack starts at the last items and pairs them whenever they are
    # similar, so it always pairs the common suffix item by item.
    def pair_common_suffix
      pair_and_step while a_index >= 0 && b_index >= 0 && similar_at?(a_index, b_index)
    end

    def common_prefix_length
      length = 0
      length += 1 while length <= a_index && length <= b_index && similar_at?(length, length)
      length
    end

    # Each cell holds the length of the LCS of the items up to it, and the
    # direction the backtrack takes from it. When both directions give the
    # same length it goes left.
    #
    # Past a common prefix, the lengths in a full table are the ones in this
    # table plus the prefix length, so both backtracks take the same steps.
    def build_table(start)
      a_items = arraya[start...a_index + 1]
      b_items = arrayb[start...b_index + 1]
      table = []
      b_items.each_with_index do |b_item, bi|
        above = table[bi - 1] if bi > 0
        row = table[bi] = []
        a_items.each_with_index do |a_item, ai|
          row[ai] = if Hashdiff.similar?(a_item, b_item, options)
                      [:topleft, (above && ai > 0 ? above[ai - 1][1] : 0) + 1]
                    else
                      top = above ? above[ai][1] : 0
                      left = ai > 0 ? row[ai - 1][1] : 0
                      top > left ? [:top, top] : [:left, left]
                    end
        end
      end
      table
    end

    # Cells of length 0 point left, so once the middle has no more pairs the
    # backtrack leaves the table into the prefix, as a full table's would.
    def backtrack(table, start)
      while a_index >= start && b_index >= start
        direction = table[b_index - start][a_index - start].first
        if direction == :topleft
          pair_and_step
        elsif direction == :top
          self.b_index = b_index - 1
        else
          self.a_index = a_index - 1
        end
      end
    end

    # Takes the steps a full table would take once an index is in the prefix:
    # it pairs similar items and otherwise steps towards the diagonal, where
    # items are known to be similar. So the last prefix item can pair with a
    # later copy:
    #
    #     lcs(%w[x w], %w[x x z]) # => [[0, 1]]
    def backtrack_through_prefix
      while a_index >= 0 && b_index >= 0
        if a_index == b_index || similar_at?(a_index, b_index)
          pair_and_step
        elsif b_index > a_index
          self.b_index = b_index - 1
        else
          self.a_index = a_index - 1
        end
      end
    end

    def similar_at?(index_a, index_b)
      Hashdiff.similar?(arraya[index_a], arrayb[index_b], options)
    end

    def pair_and_step
      pairs << [a_index, b_index]
      self.a_index = a_index - 1
      self.b_index = b_index - 1
    end
  end
end
