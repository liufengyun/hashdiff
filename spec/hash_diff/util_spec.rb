require 'spec_helper'

describe HashDiff do
  it "should be able to decode property path" do
    decoded = HashDiff.send(:decode_property_path, "a.b[0].c.city[5]")
    decoded.should == ['a', 'b', 0, 'c', 'city', 5]
  end
end

