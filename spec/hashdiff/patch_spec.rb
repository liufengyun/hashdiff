require 'spec_helper'

describe HashDiff do
  it "it should be able to patch key addition" do
    a = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200}
    b = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200, "g"=>300}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200}
    b = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200, "g"=>300}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value type changes" do
    a = {"a" => 3}
    b = {"a" => {"a1" => 1, "a2" => 2}}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 3}
    b = {"a" => {"a1" => 1, "a2" => 2}}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value array <=> []" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => []}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => []}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value array <=> nil" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => nil}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => nil}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch array value removal" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch hash value removal" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value hash <=> {}" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => {}}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => {}}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value hash <=> nil" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => nil}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => nil}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch value nil removal" do
    a = {"a" => 1, "b" => nil}
    b = {"a" => 1}
    diff = HashDiff.diff(a, b)

    HashDiff.patch!(a, diff).should == b

    a = {"a" => 1, "b" => nil}
    b = {"a" => 1}
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch similar objects between arrays" do
    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, 3]
    b = [1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}]

    diff = HashDiff.diff(a, b)
    HashDiff.patch!(a, diff).should == b

    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, 3]
    b = [1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}]
    HashDiff.unpatch!(b, diff).should == a
  end

  it "should be able to patch similar & equal objects between arrays" do
    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, {'x' => 5, 'y' => 6, 'z' => 3}, 1]
    b = [1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}]

    diff = HashDiff.diff(a, b)
    HashDiff.patch!(a, diff).should == b

    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, {'x' => 5, 'y' => 6, 'z' => 3}, 1]
    b = [1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}]
    HashDiff.unpatch!(b, diff).should == a
  end

end
