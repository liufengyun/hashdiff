# Change Log

## v0.3.7 2017-10-08

* remove 1.8.7 support from gemspec #39

## v0.3.6 2017-08-22

* add option `use_lcs` #35

## v0.3.5 2017-08-06

* add option `array_path` #34

## v0.3.4 2017-05-01

* performance improvement of HashDiff#similar? #31

## v0.3.2 2016-12-27

* replace `Fixnum` by `Integer` #28

## v0.3.1 2016-11-24

* fix an error when a hash has mixed types #26

## v0.3.0 2016-2-11

* support `:case_insensitive` option

## v0.2.3 2015-11-5

* improve performance of LCS algorithm #12

## v0.2.2 2014-10-6

* make library 1.8.7 compatible

## v0.2.1 2014-7-13

* yield added/deleted keys for custom comparison

## v0.2.0 2014-3-29

* support custom comparison blocks
* support `:strip`, `:numeric_tolerance` and `:strict` options

## v0.1.0 2013-8-25

* use options for parameters `:delimiter` and `:similarity` in interfaces

## v0.0.6 2013-3-2

* Add parameter for custom property-path delimiter.

## v0.0.5 2012-7-1

* fix a bug in judging whehter two objects are similiar.
* add more spec test for HashDiff.best_diff

## v0.0.4 2012-6-24

Main changes in this version is to output the whole object in addition & deletion, instead of recursely add/deletes the object.

For example, `diff({a:2, c:[4, 5]}, {a:2}) will generate following output:

    [['-', 'c', [4, 5]]]

instead of following:

    [['-', 'c[0]', 4], ['-', 'c[1]', 5], ['-', 'c', []]]

