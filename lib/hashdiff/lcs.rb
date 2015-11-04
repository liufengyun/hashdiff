module HashDiff
  # @private
  #
  # caculate array difference using LCS algorithm
  # http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
  def self.lcs(a, b, options = {})
    opts = { :similarity => 0.8 }.merge!(options)

    opts[:prefix] = "#{opts[:prefix]}[*]"

    return [] if a.size == 0 or b.size == 0

    a_start = b_start = 0
    a_finish = a.size - 1
    b_finish = b.size - 1
    vector = []

    lcs = []
    (b_start..b_finish).each do |bi|
      lcs[bi] = [] 
      (a_start..a_finish).each do |ai|
        if similar?(a[ai], b[bi], opts)
          topleft = (ai > 0 and bi > 0)? lcs[bi-1][ai-1][1] : 0
          lcs[bi][ai] = [:topleft, topleft + 1]
        elsif
          top = (bi > 0)? lcs[bi-1][ai][1] : 0
          left = (ai > 0)? lcs[bi][ai-1][1] : 0
          count = (top > left) ? top : left

          direction = :both
          if top > left
            direction = :top
          elsif top < left
            direction = :left
          else
            if bi == 0
              direction = :top
            elsif ai == 0
              direction = :left
            else
              direction = :both
            end
          end

          lcs[bi][ai] = [direction, count]
        end
      end
    end

    x = a_finish
    y = b_finish
    while x >= 0 and y >= 0 and lcs[y][x][1] > 0
      if lcs[y][x][0] == :both
        x -= 1
      elsif lcs[y][x][0] == :topleft
        vector.insert(0, [x, y])
        x -= 1
        y -= 1
      elsif lcs[y][x][0] == :top
        y -= 1
      elsif lcs[y][x][0] == :left
        x -= 1
      end
    end

    vector
  end

end
