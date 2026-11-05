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

    def call
      backtrack(build_table)
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

    # Each cell holds the length of the LCS of the items up to it, and the
    # direction the backtrack takes from it. When both directions give the
    # same length it goes left.
    def build_table
      table = []
      arrayb.each_with_index do |b_item, bi|
        above = table[bi - 1] if bi > 0
        row = table[bi] = []
        arraya.each_with_index do |a_item, ai|
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

    def backtrack(table)
      while a_index >= 0 && b_index >= 0
        direction, length = table[b_index][a_index]
        break if length.zero?

        if direction == :topleft
          pair_and_step
        elsif direction == :top
          self.b_index = b_index - 1
        else
          self.a_index = a_index - 1
        end
      end
    end

    def pair_and_step
      pairs << [a_index, b_index]
      self.a_index = a_index - 1
      self.b_index = b_index - 1
    end
  end
end
