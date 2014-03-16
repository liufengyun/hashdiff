# HashDiff [![Build Status](https://secure.travis-ci.org/liufengyun/hashdiff.png)](http://travis-ci.org/liufengyun/hashdiff) [![Gem Version](https://badge.fury.io/rb/hashdiff.png)](http://badge.fury.io/rb/hashdiff)

HashDiff is a ruby library to compute the smallest difference between two hashes.

**Demo**: [HashDiff](http://hashdiff.herokuapp.com/)

**Docs**: [Documentation](http://rubydoc.info/gems/hashdiff)

## Why HashDiff?

Given two Hashes A and B, sometimes you face the question: what's the smallest changes that can be made to change A to B?

An algorithm that responds to this question has to do following:

* Generate a list of additions, deletions and changes, so that `A + ChangeSet = B` and `B - ChangeSet = A`.
* Compute recursively -- Arrays and Hashes may be nested arbitrarily in A or B.
* Compute the smallest change -- it should recognize similar child Hashes or child Arrays between A and B.

HashDiff answers the question above in an opinionated approach:

* Hash can be represented as a list of (dot-syntax-path, value) pairs. For example, `{a:[{c:2}]}` can be represented as `["a[0].c", 2]`.
* The change set can be represented using the dot-syntax representation. For example, `[['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]`.
* It compares Arrays using LCS(longest common subsequence) algorithm.
* It recognizes similar Hashes in an Array using a similarity value (0 < similarity <= 1).

## Usage

If you're using bundler, add the following to the Gemfile:

    gem 'hashdiff'

Or, you can run `gem install hashdiff`, then add the following line to your ruby file which uses HashDiff:

    require 'hashdiff'

## Quick Start

### Diff

Two simple hashes:

    a = {a:3, b:2}
    b = {}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a', 3], ['-', 'b', 2]]

More complex hashes:

    a = {a:{x:2, y:3, z:4}, b:{x:3, z:45}}
    b = {a:{y:3}, b:{y:3, z:30}}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a.x', 2], ['-', 'a.z', 4], ['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]

Arrays in hashes:

    a = {a:[{x:2, y:3, z:4}, {x:11, y:22, z:33}], b:{x:3, z:45}}
    b = {a:[{y:3}, {x:11, z:33}], b:{y:22}}

    diff = HashDiff.best_diff(a, b)
    diff.should == [['-', 'a[0].x', 2], ['-', 'a[0].z', 4], ['-', 'a[1].y', 22], ['-', 'b.x', 3], ['-', 'b.z', 45], ['+', 'b.y', 22]]

### Patch

patch example:

    a = {a: 3}
    b = {a: {a1: 1, a2: 2}}

    diff = HashDiff.diff(a, b)
    HashDiff.patch!(a, diff).should == b

unpatch example:

    a = [{a: 1, b: 2, c: 3, d: 4, e: 5}, {x: 5, y: 6, z: 3}, 1]
    b = [1, {a: 1, b: 2, c: 3, e: 5}]

    diff = HashDiff.diff(a, b) # diff two array is OK
    HashDiff.unpatch!(b, diff).should == a

### Options

There are three options available: `:delimiter`, `:similarity`, and `:comparison`.

#### `:delimiter`

You can specify `:delimiter` to be something other than the default dot. For example:

    a = {a:{x:2, y:3, z:4}, b:{x:3, z:45}}
    b = {a:{y:3}, b:{y:3, z:30}}

    diff = HashDiff.diff(a, b, :delimiter => '\t')
    diff.should == [['-', 'a\tx', 2], ['-', 'a\tz', 4], ['-', 'b\tx', 3], ['~', 'b\tz', 45, 30], ['+', 'b\ty', 3]]

#### `:similarity`

In cases where you have similar hash objects in arrays, you can pass a custom value for `:similarity` instead of the default `0.8`.  This is interpreted as a ratio of similarity (default is 80% similar, whereas `:similarity => 0.5` would look for at least a 50% similarity).

#### `:comparison`

By default, values will be compared exactly (using `==`).  However, there are situations in which you may want to use a different comparison method.

You have two options for using a different comparison method:

1. Specifying built-in numeric and string tolerance options:

        a = {x:5, y:3.75, z:7, a:[3, 4.45], s:'foo '}
        b = {x:6, y:3.76, z:7, a:[3, 4.47], s:'foo'}

        # without :numeric_tolerance or :strip, numbers and strings are compared exactly
        diff = HashDiff.diff(a, b)
        diff.should == [["~", "x", 5, 6], ["~", "y", 3.75, 3.76], ["-", "w[1]", 4.45], ["+", "w[1]", 4.47], ["~", "s", 'foo ', 'foo']]

        # the :numeric_tolerance option allows for a small numeric tolerance
        diff = HashDiff.diff(a, b, :comparison => { :numeric_tolerance => 0.1 })
        diff.should == [["~", "x", 5, 6], ["~", "s", 'foo ', 'foo']]

        # the :strip option strips all strings before comparing
        diff = HashDiff.diff(a, b, :comparison => { :numeric_tolerance => 0.1, :strip => true })
        diff.should == [["~", "x", 5, 6]]

2. Specifying a custom comparison method:

        a = {a:'car', b:'boat', c:'plane'}
        b = {a:'bus', b:'truck', c:' plan'}

        # you can specify a proc as the :comparison option...
        comparison_proc = lambda do |path, obj1, obj2|
          obj1.length == obj2.length
        end
        diff = HashDiff.diff(a, b, :comparison => comparison_proc)
        diff.should == [['~', 'b', 'boat', 'truck']]

        # ...or you can use a block.
        diff = HashDiff.diff(a, b) do |path, obj1, obj2|
          obj1.length == obj2.length
        end
        diff.should == [['~', 'b', 'boat', 'truck']]

  When using a custom comparison method, the yielded params will be `|path, obj1, obj2|`, in which path is the key (or delimited compound key) to the value being compared.

## Contributors

- [@liufengyun](https://github.com/liufengyun)
- [@m-o-e](https://github.com/m-o-e)

## License

HashDiff is distributed under the MIT-LICENSE.

