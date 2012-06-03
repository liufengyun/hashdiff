HashDiff
=========

HashDiff is a ruby library to compute the smallest difference between two hashes.

**Demo**: [HashDiff](http://hashdiff.herokuapp.com/)

**Docs**: [Documentation](http://rubydoc.info/gems/hashdiff)

Requirements
------------
HashDiff is tested on following platforms:

- 1.8.7
- 1.9.2
- 1.9.3
- rbx
- rbx-2.0
- ree
- jruby
- ruby-head

Usage
------------
If you're using bundler, add following to the Gemfile:

    gem 'hashdiff'

Or, you can run `gem install hashdiff`, then add following line to your ruby file which uses HashDiff:

    require 'hashdiff'

Quick Start
-----------


### Diff

Two simple hash:

    a = {a:3, b:2}
    b = {}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a', 3], ['-', 'b', 2]]

More complex hash:

    a = {a:{x:2, y:3, z:4}, b:{x:3, z:45}}
    b = {a:{y:3}, b:{y:3, z:30}}

    diff = HashDiff.diff(a, b)
    diff.should == [['-', 'a.x', 2], ['-', 'a.z', 4], ['-', 'b.x', 3], ['~', 'b.z', 45, 30], ['+', 'b.y', 3]]

Array in hash:

    a = {a:[{x:2, y:3, z:4}, {x:11, y:22, z:33}], b:{x:3, z:45}}
    b = {a:[{y:3}, {x:11, z:33}], b:{y:22}}

    diff = HashDiff.best_diff(a, b)
    diff.should == [['-', 'a[0].x', 2], ['-', 'a[0].z', 4], ['-', 'a[1].y', 22], ['-', 'b.x', 3], ['-', 'b.z', 45], ['+', 'b.y', 22]]

### Patch

patch example:

    a = {a: 3}
    b = {a: {a1: 1, a2: 2}}

    diff = HashDiff.diff(a, b)
    HashDiff.patch(a, diff).should == b

unpatch example:

    a = [{a: 1, b: 2, c: 3, d: 4, e: 5}, {x: 5, y: 6, z: 3}, 1]
    b = [1, {a: 1, b: 2, c: 3, e: 5}]

    diff = HashDiff.diff(a, b) # diff two array is OK
    HashDiff.unpatch(b, diff).should == a


License
-------

HashDiff is distributed under the MIT-LICENSE.

