# frozen_string_literal: true

require 'spec_helper'

describe Hashdiff do
  it 'is able to find LCS between two equal array' do
    a = [1, 2, 3]
    b = [1, 2, 3]

    lcs = described_class.lcs(a, b)
    lcs.should == [[0, 0], [1, 1], [2, 2]]
  end

  it 'is able to find LCS between two close arrays' do
    a = [1.05, 2, 3.25]
    b = [1.06, 2, 3.24]

    lcs = described_class.lcs(a, b, numeric_tolerance: 0.1)
    lcs.should == [[0, 0], [1, 1], [2, 2]]
  end

  it 'strips strings when finding LCS if requested' do
    a = %w[foo bar baz]
    b = [' foo', 'bar', 'zab']

    lcs = described_class.lcs(a, b, strip: true)
    lcs.should == [[0, 0], [1, 1]]
  end

  it 'is able to find LCS with one common elements' do
    a = [1, 2, 3]
    b = [1, 8, 7]

    lcs = described_class.lcs(a, b)
    lcs.should == [[0, 0]]
  end

  it 'is able to find LCS with two common elements' do
    a = [1, 3, 5, 7]
    b = [2, 3, 7, 5]

    lcs = described_class.lcs(a, b)
    lcs.should == [[1, 1], [2, 3]]
  end

  it 'is able to find LCS with two close elements' do
    a = [1, 3.05, 5, 7]
    b = [2, 3.06, 7, 5]

    lcs = described_class.lcs(a, b, numeric_tolerance: 0.1)
    lcs.should == [[1, 1], [2, 3]]
  end

  it 'is able to find LCS with two common elements in different ordering' do
    a = [1, 3, 4, 7]
    b = [2, 3, 7, 5]

    lcs = described_class.lcs(a, b)
    lcs.should == [[1, 1], [3, 2]]
  end

  it 'is able to find LCS with a similarity value' do
    a = [
      { 'value' => 'New', 'onclick' => 'CreateNewDoc()' },
      { 'value' => 'Close', 'onclick' => 'CloseDoc()' }
    ]
    b = [
      { 'value' => 'New1', 'onclick' => 'CreateNewDoc()' },
      { 'value' => 'Open', 'onclick' => 'OpenDoc()' },
      { 'value' => 'Close', 'onclick' => 'CloseDoc()' }
    ]

    lcs = described_class.lcs(a, b, similarity: 0.5)
    lcs.should == [[0, 0], [1, 2]]
  end

  it 'passes the item of the first array to a comparison block before the one of the second' do
    a = [1, 3]
    b = [2]

    lcs = described_class.lcs(a, b, comparison: ->(_prefix, obj1, obj2) { obj1 < obj2 })
    lcs.should == [[0, 0]]
  end

  it 'compares arrays that differ in one place in linear time' do
    a = [true, false] * 10
    b = a.dup
    b[a.size / 2] = nil

    calls = 0
    comparison = lambda do |_prefix, obj1, obj2|
      calls += 1
      obj1 == obj2
    end

    described_class.lcs(a, b, comparison: comparison)
    calls.should be <= 2 * a.size
  end

  it 'compares arrays that differ in several places in linear time' do
    a = (1..100).to_a
    b = a.dup
    b.delete_at(10)
    b.insert(50, -1)
    b[90] = -2

    calls = 0
    comparison = lambda do |_prefix, obj1, obj2|
      calls += 1
      obj1 == obj2
    end

    described_class.lcs(a, b, comparison: comparison)
    calls.should be <= 2 * a.size
  end

  it 'makes only two comparisons more than there are items when one item changed' do
    a = (1..20).to_a
    b = a.dup
    b[10] = -1

    calls = 0
    comparison = lambda do |_prefix, obj1, obj2|
      calls += 1
      obj1 == obj2
    end

    described_class.lcs(a, b, comparison: comparison)
    calls.should be <= a.size + 2
  end

  it 'does not compare the same items over and over when the arrays have nothing in common' do
    a = (1..10).to_a
    b = (11..20).to_a

    calls = 0
    comparison = lambda do |_prefix, obj1, obj2|
      calls += 1
      obj1 == obj2
    end

    described_class.lcs(a, b, comparison: comparison)
    calls.should be <= (a.size * b.size) + a.size + b.size
  end

  it 'pairs every item but the changed ones when they are in several places' do
    a = (1..100).to_a
    b = a.dup
    b.delete_at(10)
    b.insert(50, -1)
    b[90] = -2

    lcs = described_class.lcs(a, b)
    lcs.should == (0...10).map { |i| [i, i] } +
                  (10...50).map { |i| [i + 1, i] } +
                  (51...100).reject { |i| i == 90 }.map { |i| [i, i] }
  end

  it 'pairs the common prefix and suffix around a change' do
    a = [1, 2, 3, 4, 5]
    b = [1, 2, 9, 4, 5]

    lcs = described_class.lcs(a, b)
    lcs.should == [[0, 0], [1, 1], [3, 3], [4, 4]]
  end

  it 'pairs a common first item with a later copy in the second array' do
    a = %w[x w]
    b = %w[x x z]

    lcs = described_class.lcs(a, b)
    lcs.should == [[0, 1]]
  end

  it 'pairs a common first item with a later copy in the first array' do
    a = %w[x x y]
    b = %w[x]

    lcs = described_class.lcs(a, b)
    lcs.should == [[1, 0]]
  end

  it 'pairs a common item with a later copy in the first array when other items surround it' do
    a = %w[a a b]
    b = %w[c a]

    lcs = described_class.lcs(a, b)
    lcs.should == [[1, 1]]
  end

  it 'pairs the items a table of LCS lengths pairs, where the backtrack of Myers\' paper pairs others' do
    a = %w[A B C A B B A]
    b = %w[C B A B A C]

    lcs = described_class.lcs(a, b)
    lcs.should == [[1, 1], [3, 2], [5, 3], [6, 4]] # the paper pairs [[2, 0], [3, 2], [4, 3], [6, 4]]
  end
end
