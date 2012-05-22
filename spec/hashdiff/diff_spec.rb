require 'spec_helper'

describe HashDiff do
  it "should be able to diff two empty hashes" do
    diff = HashDiff.diff({}, {})
    diff.should == []
  end

  it "should be able to diff an hash with an empty hash" do
    a = {a:3, b:2}
    b = {}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a', 3], ['-', 'b', 2]]

    diff = HashDiff.diff(b, a)
    diff.should == [['+', 'a', 3], ['+', 'b', 2]]
  end

  it "should be able to diff two equal hashes" do
    diff = HashDiff.diff({a:2, b:2}, {a:2, b:2})
    diff.should == []
  end

  it "should be able to diff changes in hash value which is array" do
    diff = HashDiff.diff({a:2, b:[1, 2, 3]}, {a:2, b:[1, 3, 4]})
    diff.should == [['-', 'b[1]', 2], ['+', 'b[2]', 4]]
  end

  it "should be able to diff changes in hash value which is hash" do
    diff = HashDiff.diff({a:{x:2, y:3, z:4}, b:{x:3, z:45}}, {a:{y:3}, b:{y:3, z:30}})
    diff.should == [['-', 'a.x', 2], ['-', 'a.z', 4], ['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]
  end

  it "should be able to diff similar objects in array" do
    diff = HashDiff.best_diff({a:[{x:2, y:3, z:4}, {x:11, y:22, z:33}], b:{x:3, z:45}}, {a:[{y:3}, {x:11, z:33}], b:{y:22}})
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
    diff.should  == [['-', 'a', 3], ['+', 'a', {}], ['+', 'a.a1', 1], ['+', 'a.a2', 2]]

    diff = HashDiff.diff(b, a)
    diff.should  == [['-', 'a.a1', 1], ['-', 'a.a2', 2], ['-', 'a', {}], ['+', 'a', 3]]
  end

  it "should be able to diff value changes: array <=> []" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => []}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b[1]', 2], ['-', 'b[0]', 1]]
  end

  # treat nil as empty array
  it "should be able to diff value changes: array <=> nil" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1, "b" => nil}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b[1]', 2], ['-', 'b[0]', 1]]
  end

  it "should be able to diff value chagnes: remove array completely" do
    a = {"a" => 1, "b" => [1, 2]}
    b = {"a" => 1}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b[1]', 2], ['-', 'b[0]', 1], ['-', 'b', []]]
  end

  it "should be able to diff value changes: remove whole hash" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b.b1', 1], ['-', 'b.b2', 2], ['-', 'b', {}]]
  end

  it "should be able to diff value changes: hash <=> {}" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => {}}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b.b1', 1], ['-', 'b.b2', 2]]
  end

  # treat nil as empty hash
  it "should be able to diff value changes: hash <=> nil" do
    a = {"a" => 1, "b" => {"b1" => 1, "b2" =>2}}
    b = {"a" => 1, "b" => nil}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'b.b1', 1], ['-', 'b.b2', 2]]
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
    diff.should == [['-', '[0].d', 4], ['-', '[1].x', 5], ['-', '[1].y', 6], ['-', '[1].z', 3], ['-', '[1]', {}]]
  end

  it "should be able to best diff" do
    a = {'x' => [{'a' => 1, 'c' => 3, 'e' => 5}, {'y' => 3}]}
    b = {'x' => [{'a' => 1, 'b' => 2, 'e' => 5}] }

    diff = HashDiff.best_diff(a, b)
    diff.should == [['-', 'x[0].c', 3], ['+', 'x[0].b', 2], ['-', 'x[1].y', 3], ['-', 'x[1]', {}]]
  end

end

