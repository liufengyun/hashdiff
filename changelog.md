# Change Log

## v0.0.5 2012-7-1

* fix a bug in judging whehter two objects are similiar.
* add more spec test for HashDiff.best_diff

## v0.0.4 2012-6-24

Main changes in this version is to output the whole object in addition & deletion, instead of recursely add/deletes the object.

For example, `diff({a:2, c:[4, 5]}, {a:2}) will generate following output:

    [['-', 'c', [4, 5]]]

instead of following:

    [['-', 'c[0]', 4], ['-', 'c[1]', 5], ['-', 'c', []]]

