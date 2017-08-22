require 'spec_helper'

describe HashDiff::LinearCompareArray do
  it "should find no differences between two empty arrays" do
    difference = described_class.call([], [])
    difference.should == []
  end

  it "should find added items when the old array is empty" do
    difference = described_class.call([], [:a, :b])
    difference.should == [['+', '[0]', :a], ['+', '[1]', :b]]
  end

  it "should find removed items when the new array is empty" do
    difference = described_class.call([:a, :b], [])
    difference.should == [['-', '[1]', :b], ['-', '[0]', :a]]
  end

  it "should find no differences between identical arrays" do
    difference = described_class.call([:a, :b], [:a, :b])
    difference.should == []
  end

  it "should find added items in an array" do
    difference = described_class.call([:a, :d], [:a, :b, :c, :d])
    difference.should == [['+', '[1]', :b], ['+', '[2]', :c]]
  end

  it "should find removed items in an array" do
    difference = described_class.call([:a, :b, :c, :d, :e, :f], [:a, :d, :f])
    difference.should == [['-', '[4]', :e], ['-', '[2]', :c], ['-', '[1]', :b]]
  end

  it "should show additions and deletions as changed items" do
    difference = described_class.call([:a, :b, :c], [:c, :b, :a])
    difference.should == [['~', '[0]', :a, :c], ['~', '[2]', :c, :a]]
  end

  it "should show changed items in a hash" do
    difference = described_class.call([{ :a => :b }], [{ :a => :c }])
    difference.should == [['~', '[0].a', :b, :c]]
  end

  it "should show changed items and added items" do
    difference = described_class.call([{ :a => 1, :b => 2 }], [{ :a => 2, :b => 2 }, :item])
    difference.should == [['~', '[0].a', 1, 2], ['+', '[1]', :item]]
  end
end
