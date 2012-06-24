require 'spec_helper'

describe HashDiff do
  it "should be able to decode property path" do
    decoded = HashDiff.send(:decode_property_path, "a.b[0].c.city[5]")
    decoded.should == ['a', 'b', 0, 'c', 'city', 5]
  end

  it "should be able to tell similiar hash" do
    a = {'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}
    b = {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}
    HashDiff.similar?(a, b).should be_true
    HashDiff.similar?(a, b, 1).should be_false
  end

  it "should be able to tell numbers and strings" do
    HashDiff.similar?(1, 2).should_not be_true
    HashDiff.similar?("a", "b").should_not be_true
    HashDiff.similar?("a", [1, 2, 3]).should_not be_true
    HashDiff.similar?(1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}).should_not be_true
  end
end

