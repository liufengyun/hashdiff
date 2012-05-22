require 'spec_helper'

describe HashDiff do
  it "should be able to find LCS between two equal array" do
    a = [1, 2, 3]
    b = [1, 2, 3]

    lcs = HashDiff.lcs(a, b)
    lcs.should == [[0, 0], [1, 1], [2, 2]]
  end

  it "should be able to find LCS with one common elements" do
    a = [1, 2, 3]
    b = [1, 8, 7]

    lcs = HashDiff.lcs(a, b)
    lcs.should == [[0, 0]]
  end

  it "should be able to find LCS with two common elements" do
    a = [1, 3, 5, 7]
    b = [2, 3, 7, 5]

    lcs = HashDiff.lcs(a, b)
    lcs.should == [[1, 1], [2, 3]]
  end

  it "should be able to find LCS with two common elements in different ordering" do
    a = [1, 3, 4, 7]
    b = [2, 3, 7, 5]

    lcs = HashDiff.lcs(a, b)
    lcs.should == [[1, 1], [3, 2]]
  end
end

