require 'spec_helper'

describe HashDiff do
  it "should be able to diff two empty hashes" do
    diff = HashDiff.diff({}, {})
    diff.should == []
  end

  it "should be able to diff an hash with an empty hash" do
    a = { 'a' => 3, 'b' => 2 }
    b = {}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a', 3], ['-', 'b', 2]]

    diff = HashDiff.diff(b, a)
    diff.should == [['+', 'a', 3], ['+', 'b', 2]]
  end

  it "should be able to diff two equal hashes" do
    diff = HashDiff.diff({ 'a' => 2, 'b' => 2}, { 'a' => 2, 'b' => 2 })
    diff.should == []
  end

  it "should be able to diff two hashes with equivalent numerics, when strict is false" do
    diff = HashDiff.diff({ 'a' => 2.0, 'b' => 2 }, { 'a' => 2, 'b' => 2.0 }, :strict => false)
    diff.should == []
  end

  it "should be able to diff changes in hash value" do
    diff = HashDiff.diff({ 'a' => 2, 'b' => 3, 'c' => " hello" }, { 'a' => 2, 'b' => 4, 'c' => "hello" })
    diff.should == [['~', 'b', 3, 4], ['~', 'c', " hello", "hello"]]
  end

  it "should be able to diff changes in hash value which is array" do
    diff = HashDiff.diff({ 'a' => 2, 'b' => [1, 2, 3] }, { 'a' => 2, 'b' => [1, 3, 4]})
    diff.should == [['-', 'b[1]', 2], ['+', 'b[2]', 4]]
  end

  it "should be able to diff changes in hash value which is hash" do
    diff = HashDiff.diff({ 'a' => { 'x' => 2, 'y' => 3, 'z' => 4 }, 'b' => { 'x' => 3, 'z' => 45 } },
                         { 'a' => { 'y' => 3 }, 'b' => { 'y' => 3, 'z' => 30 } })
    diff.should == [['-', 'a.x', 2], ['-', 'a.z', 4], ['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]
  end

  it "should be able to diff similar objects in array" do
    diff = HashDiff.best_diff({ 'a' => [{ 'x' => 2, 'y' => 3, 'z' => 4 }, { 'x' => 11, 'y' => 22, 'z' => 33 }], 'b' => { 'x' => 3, 'z' => 45 } },
                              { 'a' => [{ 'y' => 3 }, { 'x' => 11, 'z' => 33 }], 'b' => { 'y' => 22 } })
    diff.should == [['-', 'a[0].x', 2], ['-', 'a[0].z', 4], ['-', 'a[1].y', 22], ['-', 'b.x', 3], ['-', 'b.z', 45], ['+', 'b.y', 22]]
  end

  it 'should be able to diff addition of key value pair' do
    a = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200}
    b = {"a"=>3, "c"=>11, "d"=>45, "e"=>100, "f"=>200, "g"=>300}

    diff = HashDiff.diff(a, b)
    diff.should == [['+', 'g', 300]]

    diff = HashDiff.diff(b, a)
    diff.should == [['-', 'g', 300]]
  end

  it 'should be able to diff value type changes' do
    a = {"a" => 3}
    b = {"a" => {"a1" => 1, "a2" => 2}}

    diff = HashDiff.diff(a, b)
    diff.should  == [['~', 'a', 3, {"a1" => 1, "a2" => 2}]]

    diff = HashDiff.diff(b, a)
    diff.should  == [['~', 'a', {"a1" => 1, "a2" => 2}, 3]]
  end

  it "should be able to diff value changes: array <=> []" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => []}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b[1]', 2], ['-', 'b[0]', 1]]
  end

  it "should be able to diff value changes: array <=> nil" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => nil}

    diff = HashDiff.diff(a, b)
    diff.should == [["~", "b", [1, 2], nil]]
  end

  it "should be able to diff value chagnes: remove array completely" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1}

    diff = HashDiff.diff(a, b)
    diff.should == [["-", "b", [1, 2]]]
  end

  it "should be able to diff value changes: remove whole hash" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1}

    diff = HashDiff.diff(a, b)
    diff.should == [["-", "b", {"b1"=>1, "b2"=>2}]]
  end

  it "should be able to diff value changes: hash <=> {}" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => {}}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b.b1', 1], ['-', 'b.b2', 2]]
  end

  it "should be able to diff value changes: hash <=> nil" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => nil}

    diff = HashDiff.diff(a, b)
    diff.should == [["~", "b", {"b1"=>1, "b2"=>2}, nil]]
  end

  it "should be able to diff similar objects in array" do
    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, 3]
    b = [1, {'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}]

    diff = HashDiff.diff(a, b)
    diff.should == [['-', '[0].d', 4], ['+', '[0]', 1], ['-', '[2]', 3]]
  end

  it "should be able to diff similar & equal objects in array" do
    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, {'x' => 5, 'y' => 6, 'z' => 3}, 3]
    b = [{'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}, 3]

    diff = HashDiff.diff(a, b)
    diff.should == [["-", "[0].d", 4], ["-", "[1]", {"x"=>5, "y"=>6, "z"=>3}]]
  end

  it "should use custom delimiter when provided" do
    a = [{'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5}, {'x' => 5, 'y' => 6, 'z' => 3}, 3]
    b = [{'a' => 1, 'b' => 2, 'c' => 3, 'e' => 5}, 3]

    diff = HashDiff.diff(a, b, :similarity => 0.8, :delimiter => "\t")
    diff.should == [["-", "[0]\td", 4], ["-", "[1]", {"x"=>5, "y"=>6, "z"=>3}]]
  end

  context 'when :numeric_tolerance requested' do
    it "should be able to diff changes in hash value" do
      a = {'a' => 0.558, 'b' => 0.0, 'c' => 0.65, 'd' => 'fin'}
      b = {'a' => 0.557, 'b' => 'hats', 'c' => 0.67, 'd' => 'fin'}

      diff = HashDiff.diff(a, b, :numeric_tolerance => 0.01)
      diff.should == [["~", "b", 0.0, 'hats'], ["~", "c", 0.65, 0.67]]

      diff = HashDiff.diff(b, a, :numeric_tolerance => 0.01)
      diff.should == [["~", "b", 'hats', 0.0], ["~", "c", 0.67, 0.65]]
    end

    it "should be able to diff changes in nested values" do
      a = {'a' => {'x' => 0.4, 'y' => 0.338}, 'b' => [13, 68.03]}
      b = {'a' => {'x' => 0.6, 'y' => 0.341}, 'b' => [14, 68.025]}

      diff = HashDiff.diff(a, b, :numeric_tolerance => 0.01)
      diff.should == [["~", "a.x", 0.4, 0.6], ["-", "b[0]", 13], ["+", "b[0]", 14]]

      diff = HashDiff.diff(b, a, :numeric_tolerance => 0.01)
      diff.should == [["~", "a.x", 0.6, 0.4], ["-", "b[0]", 14], ["+", "b[0]", 13]]
    end
  end

  context 'when :strip requested' do
    it "should strip strings before comparing" do
      a = { 'a' => " foo", 'b' => "fizz buzz"}
      b = { 'a' => "foo", 'b' => "fizzbuzz"}
      diff = HashDiff.diff(a, b, :strip => true)
      diff.should == [['~', 'b', "fizz buzz", "fizzbuzz"]]
    end

    it "should strip nested strings before comparing" do
      a = { 'a' => { 'x' => " foo" }, 'b' => ["fizz buzz", "nerf"] }
      b = { 'a' => { 'x' => "foo" }, 'b' => ["fizzbuzz", "nerf"] }
      diff = HashDiff.diff(a, b, :strip => true)
      diff.should == [['-', 'b[0]', "fizz buzz"], ['+', 'b[0]', "fizzbuzz"]]
    end
  end

  context 'when :case_insensitive requested' do
    it "should strip strings before comparing" do
      a = { 'a' => "Foo", 'b' => "fizz buzz"}
      b = { 'a' => "foo", 'b' => "fizzBuzz"}
      diff = HashDiff.diff(a, b, :case_insensitive => true)
      diff.should == [['~', 'b', "fizz buzz", "fizzBuzz"]]
    end

    it "should ignore case on nested strings before comparing" do
      a = { 'a' => { 'x' => "Foo" }, 'b' => ["fizz buzz", "nerf"] }
      b = { 'a' => { 'x' => "foo" }, 'b' => ["fizzbuzz", "nerf"] }
      diff = HashDiff.diff(a, b, :case_insensitive => true)
      diff.should == [['-', 'b[0]', "fizz buzz"], ['+', 'b[0]', "fizzbuzz"]]
    end
  end

  context 'when both :strip and :numeric_tolerance requested' do
    it 'should apply filters to proper object types' do
      a = { 'a' => " foo", 'b' => 35, 'c' => 'bar', 'd' => 'baz' }
      b = { 'a' => "foo", 'b' => 35.005, 'c' => 'bar', 'd' => 18.5}
      diff = HashDiff.diff(a, b, :strict => false, :numeric_tolerance => 0.01, :strip => true)
      diff.should == [['~', 'd', "baz", 18.5]]
    end
  end

  context "when both :strip and :case_insensitive requested" do
    it "should apply both filters to strings" do
      a = { 'a' => " Foo", 'b' => "fizz buzz"}
      b = { 'a' => "foo", 'b' => "fizzBuzz"}
      diff = HashDiff.diff(a, b, :case_insensitive => true, :strip => true)
      diff.should == [['~', 'b', "fizz buzz", "fizzBuzz"]]
    end
  end

  context 'with custom comparison' do
    let(:a) { { 'a' => 'car', 'b' => 'boat', 'c' => 'plane'} }
    let(:b) { { 'a' => 'bus', 'b' => 'truck', 'c' => ' plan'} }

    it 'should compare using proc specified in block' do
      diff = HashDiff.diff(a, b) do |prefix, obj1, obj2|
        case prefix
        when /a|b|c/
          obj1.length == obj2.length
        end
      end
      diff.should == [['~', 'b', 'boat', 'truck']]
    end

    it 'should yield added keys' do
      x = { 'a' => 'car', 'b' => 'boat'}
      y = { 'a' => 'car' }

      diff = HashDiff.diff(x, y) do |prefix, obj1, obj2|
        case prefix
        when /b/
          true
        end
      end
      diff.should == []
    end

    it 'should compare with both proc and :strip when both provided' do
      diff = HashDiff.diff(a, b, :strip => true) do |prefix, obj1, obj2|
        case prefix
        when 'a'
          obj1.length == obj2.length
        end
      end
      diff.should == [['~', 'b', 'boat', 'truck'], ['~', 'c', 'plane', ' plan']]
    end
  end
end
