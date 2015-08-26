# HashDiff [![Build Status](https://secure.travis-ci.org/liufengyun/hashdiff.png)](http://travis-ci.org/liufengyun/hashdiff) [![Gem Version](https://badge.fury.io/rb/hashdiff.png)](http://badge.fury.io/rb/hashdiff)

HashDiff is a ruby library to compute the smallest difference between two hashes.

**Docs**: [Documentation](http://rubydoc.info/gems/hashdiff)

## Why HashDiff?

Given two Hashes A and B, sometimes you face the question: what's the smallest modification that can be made to change A into B?

An algorithm that responds to this question has to do following:

* Generate a list of additions, deletions and changes, so that `A + ChangeSet = B` and `B - ChangeSet = A`.
* Compute recursively -- Arrays and Hashes may be nested arbitrarily in A or B.
* Compute the smallest change -- it should recognize similar child Hashes or child Arrays between A and B.

HashDiff answers the question above using an opinionated approach:

* Hash can be represented as a list of (dot-syntax-path, value) pairs. For example, `{a:[{c:2}]}` can be represented as `["a[0].c", 2]`.
* The change set can be represented using the dot-syntax representation. For example, `[['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]`.
* It compares Arrays using the [LCS(longest common subsequence)](http://en.wikipedia.org/wiki/Longest_common_subsequence_problem) algorithm.
* It recognizes similar Hashes in an Array using a similarity value (0 < similarity <= 1).

## Usage

To use the gem, add the following to your Gemfile:

```ruby
gem 'hashdiff'
```

## Quick Start

### Diff

Two simple hashes:

```ruby
a = {a:3, b:2}
b = {}

diff = HashDiff.diff(a, b)
diff.should == [['-', 'a', 3], ['-', 'b', 2]]
```

More complex hashes:

```ruby
a = {a:{x:2, y:3, z:4}, b:{x:3, z:45}}
b = {a:{y:3}, b:{y:3, z:30}}

diff = HashDiff.diff(a, b)
diff.should == [['-', 'a.x', 2], ['-', 'a.z', 4], ['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]
```

Arrays in hashes:

```ruby
a = {a:[{x:2, y:3, z:4}, {x:11, y:22, z:33}], b:{x:3, z:45}}
b = {a:[{y:3}, {x:11, z:33}], b:{y:22}}

diff = HashDiff.best_diff(a, b)
diff.should == [['-', 'a[0].x', 2], ['-', 'a[0].z', 4], ['-', 'a[1].y', 22], ['-', 'b.x', 3], ['-', 'b.z', 45], ['+', 'b.y', 22]]
```

### Patch

patch example:

```ruby
a = {a: 3}
b = {a: {a1: 1, a2: 2}}

diff = HashDiff.diff(a, b)
HashDiff.patch!(a, diff).should == b
```

unpatch example:

```ruby
a = [{a: 1, b: 2, c: 3, d: 4, e: 5}, {x: 5, y: 6, z: 3}, 1]
b = [1, {a: 1, b: 2, c: 3, e: 5}]

diff = HashDiff.diff(a, b) # diff two array is OK
HashDiff.unpatch!(b, diff).should == a
```

### Options

There are five options available: `:delimiter`, `:similarity`, `:strict`, `:numeric_tolerance` and `:strip`.

#### `:delimiter`

You can specify `:delimiter` to be something other than the default dot. For example:

```ruby
a = {a:{x:2, y:3, z:4}, b:{x:3, z:45}}
b = {a:{y:3}, b:{y:3, z:30}}

diff = HashDiff.diff(a, b, :delimiter => '\t')
diff.should == [['-', 'a\tx', 2], ['-', 'a\tz', 4], ['-', 'b\tx', 3], ['~', 'b\tz', 45, 30], ['+', 'b\ty', 3]]
```

#### `:similarity`

In cases where you have similar hash objects in arrays, you can pass a custom value for `:similarity` instead of the default `0.8`.  This is interpreted as a ratio of similarity (default is 80% similar, whereas `:similarity => 0.5` would look for at least a 50% similarity).

#### `:strict`

The `:strict` option, which defaults to `true`, specifies whether numeric types are compared on type as well as value.  By default, a Fixnum will never be equal to a Float (e.g. 4 != 4.0).  Setting `:strict` to false makes the comparison looser (e.g. 4 == 4.0).

#### `:numeric_tolerance`

The :numeric_tolerance option allows for a small numeric tolerance.

```ruby
a = {x:5, y:3.75, z:7}
b = {x:6, y:3.76, z:7}

diff = HashDiff.diff(a, b, :numeric_tolerance => 0.1)
diff.should == [["~", "x", 5, 6]]
```

#### `:strip`

The :strip option strips all strings before comparing.

```ruby
a = {x:5, s:'foo '}
b = {x:6, s:'foo'}

diff = HashDiff.diff(a, b, :comparison => { :numeric_tolerance => 0.1, :strip => true })
diff.should == [["~", "x", 5, 6]]
```

#### Specifying a custom comparison method

It's possible to specify how the values of a key should be compared.

```ruby
a = {a:'car', b:'boat', c:'plane'}
b = {a:'bus', b:'truck', c:' plan'}

diff = HashDiff.diff(a, b) do |path, obj1, obj2|
  case path
  when  /a|b|c/
    obj1.length == obj2.length
  end
end

diff.should == [['~', 'b', 'boat', 'truck']]
```

The yielded params of the comparison block is `|path, obj1, obj2|`, in which path is the key (or delimited compound key) to the value being compared. When comparing elements in array, the path is with the format `array[*]`. For example:

```ruby
a = {a:'car', b:['boat', 'plane'] }
b = {a:'bus', b:['truck', ' plan'] }

diff = HashDiff.diff(a, b) do |path, obj1, obj2|
  case path
  when 'b[*]'
    obj1.length == obj2.length
  end
end

diff.should == [["~", "a", "car", "bus"], ["~", "b[1]", "plane", " plan"], ["-", "b[0]", "boat"], ["+", "b[0]", "truck"]]
```

When a comparison block is given, it'll be given priority over other specified options. If the block returns value other than `true` or `false`, then the two values will be compared with other specified options.

#### Sorting arrays before comparison

An order difference alone between two arrays can create too many diffs to be useful. Consider sorting them prior to diffing.

```ruby
a = {a:'car', b:['boat', 'plane'] }
b = {a:'car', b:['plane', 'boat'] }

HashDiff.diff(a, b) => [["+", "b[0]", "plane"], ["-", "b[2]", "plane"]]

b[:b].sort!

HashDiff.diff(a, b) => []
```

### Special use cases

#### Using HashDiff on JSON API results

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('http://time.jsontest.com/')
json_resp = ->(uri) { JSON.parse(Net::HTTP.get_response(uri).body) }
a = json_resp.call(uri)
b = json_resp.call(uri)

HashDiff.diff(a,b) => [["~", "milliseconds_since_epoch", 1410542545874, 1410542545985]]
```

## License

HashDiff is distributed under the MIT-LICENSE.

