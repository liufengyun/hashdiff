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
  # make up the longest common subsequence of the two arrays. For arrays of n
  # and m items its work grows with (n + m) * d, d being the number of items
  # left unpaired, and not with n * m. At worst it compares each pair of items
  # about once.
  #
  # The search is the greedy algorithm of section 3 of
  #
  #   Myers, E. W. (1986). An O(ND) difference algorithm and its variations.
  #   Algorithmica, 1(1-4), 251-266. https://doi.org/10.1007/BF01840446
  #   Free copy: https://publications.mpi-cbg.de/Myers_1986_6330.pdf
  #
  # https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/ and
  # its parts 2 and 3 explain it step by step, with Ruby code.
  #
  # A position [a_pos, b_pos] stands for the first a_pos items of arraya and
  # the first b_pos items of arrayb: the paper's point (x, y). Its cost is the
  # fewest items that have to be left unpaired to get there from [0, 0], the
  # paper's D. Its diagonal is a_pos - b_pos, the paper's k: pairing two items
  # stays on the diagonal, leaving one unpaired moves to the next diagonal.
  #
  # == Where it differs from the paper
  #
  # The search finds the positions the paper's does and only saves work: the
  # common suffix is paired before it starts, and it stops following the
  # diagonals that got to the end of an array.
  #
  # The backtrack is not the paper's. Several subsequences can be as long, and
  # which one is picked decides the diff. The paper walks back along the path
  # its search took. Hashdiff used to fill a table of LCS lengths, and that
  # table's backtrack often picks another one: for A B C A B B A and
  # C B A B A C the paper pairs C A B A and the table pairs B A B A. The
  # backtrack here makes the table's choices. It uses what the search stored
  # only to tell the cost of a position.
  #
  # * For: Hashdiff.diff returns what it returned with the table, so diffs
  #   that are stored, or expected by a test, stay the same.
  # * Against: the backtrack is longer than the paper's, it compares a few
  #   pairs of items the search did not, and only the search can be read side
  #   by side with the paper.
  class Lcs
    def self.call(arraya, arrayb, options = {})
      return [] if arraya.empty? || arrayb.empty?

      new(arraya, arrayb, options).call
    end

    def call
      pair_common_suffix
      unless a_pos.zero? || b_pos.zero? # an array has no items left to pair
        explore
        backtrack
      end
      pairs.reverse
    end

    private

    attr_reader :arraya, :arrayb, :options, :pairs, :reached, :lowest
    # the position the backtrack is at, walking from the last items to the first
    attr_accessor :a_pos, :b_pos

    def initialize(arraya, arrayb, options)
      @arraya = arraya
      @arrayb = arrayb
      @options = { similarity: 0.8 }.merge!(options)
      @options[:prefix] = Hashdiff.prefix_append_array_index(@options[:prefix], '*', @options)
      @pairs = []
      @reached = [] # reached[cost]: the furthest a_pos that cost gets to on each diagonal
      @lowest = []  # lowest[cost]: the first of those diagonals, the others follow 2 apart
      self.a_pos = arraya.size
      self.b_pos = arrayb.size
    end

    # The backtrack starts at the last items and pairs them whenever they are
    # similar, so it always pairs the common suffix item by item. Pairing it
    # first leaves the search only the items before it.
    def pair_common_suffix
      pair_and_step while a_pos > 0 && b_pos > 0 && similar_at?(a_pos - 1, b_pos - 1)
    end

    # For each cost in turn, finds how far along each diagonal that cost
    # gets, until one gets to the backtrack's position. It compares each pair
    # of items at most once, and only the pairs a lower cost did not get past.
    #
    # A diagonal that gets to the end of arrayb is done, like the ones below
    # it, and so are the ones above a diagonal that gets to the end of arraya:
    # the way to the last items never goes through them again.
    #
    # This loop is where the time goes, hence the local variables.
    def explore
      a_items = arraya
      b_items = arrayb
      opts = options
      a_end = a_pos # the search is over the items before the common suffix
      b_end = b_pos
      # The paper's V: the furthest a_pos on each diagonal, -1 where no cost
      # got yet. A negative diagonal indexes it from its end.
      furthest = Array.new(a_end + b_end + 3, -1)
      low_limit = -b_end
      cost = 0
      loop do
        low = [-cost, low_limit].max
        low += 1 if (cost - low).odd? # a cost only gets to every other diagonal
        lowest << low
        reached << (row = [])
        diagonal = low
        while diagonal <= cost
          # Leave one item unpaired from the furthest position the cost before
          # got to, on the diagonal below or on the one above.
          below = furthest[diagonal - 1]
          above = furthest[diagonal + 1]
          a_at = below < above ? above : below + 1
          b_at = a_at - diagonal
          # Then pair items for as long as they are similar: the paper's snake.
          while a_at < a_end && b_at < b_end && Hashdiff.similar?(a_items[a_at], b_items[b_at], opts)
            a_at += 1
            b_at += 1
          end
          row << (furthest[diagonal] = a_at)
          if a_at >= a_end
            return if b_at >= b_end # got to the backtrack's position

            break # the diagonals above are done
          end
          low_limit = diagonal + 1 if b_at >= b_end # this one and those below are done
          diagonal += 2
        end
        cost += 1
      end
    end

    # Walks back to the first items, making the choices the backtrack of a
    # table of LCS lengths makes: it pairs the two items before its position
    # whenever they are similar, and otherwise leaves one of them unpaired.
    def backtrack
      cost = reached.size - 1
      while cost < a_pos + b_pos # the items before the position still have pairs
        if pair_before?(cost)
          pair_and_step
        else
          leave_one_unpaired(cost)
          cost -= 1
        end
      end
    end

    # Steps to the position before that the cost before gets to. When it gets
    # to both, it leaves the item of arraya unpaired.
    def leave_one_unpaired(cost)
      if a_pos - 1 <= reached_at(cost - 1, a_pos - b_pos - 1)
        self.a_pos = a_pos - 1
      else
        self.b_pos = b_pos - 1
      end
    end

    # Whether the two items before the backtrack's position are similar. The
    # search already knows for the ones it compared: those on the run of
    # similar items the cost made on this diagonal, and the one that stopped
    # this diagonal's run two costs earlier.
    def pair_before?(cost)
      diagonal = a_pos - b_pos
      from_below = reached_at(cost - 1, diagonal - 1)
      from_above = reached_at(cost - 1, diagonal + 1)
      return true if a_pos > (from_below < from_above ? from_above : from_below + 1)
      return false if a_pos - 1 == reached_at(cost - 2, diagonal)

      similar_at?(a_pos - 1, b_pos - 1)
    end

    # The furthest a_pos the cost gets to on the diagonal, -1 when it cannot
    # get to the diagonal at all. The backtrack only stands on a cheapest way
    # to the last items, so it never asks about a diagonal the search dropped.
    def reached_at(cost, diagonal)
      return -1 if diagonal.abs > cost

      reached[cost].fetch((diagonal - lowest[cost]) / 2)
    end

    def pair_and_step
      self.a_pos = a_pos - 1
      self.b_pos = b_pos - 1
      pairs << [a_pos, b_pos]
    end

    def similar_at?(index_a, index_b)
      Hashdiff.similar?(arraya[index_a], arrayb[index_b], options)
    end
  end
end
