# frozen_string_literal: true

require 'hashdiff/util'
require 'hashdiff/compare_hashes'
require 'hashdiff/lcs'
require 'hashdiff/lcs_compare_arrays'
require 'hashdiff/linear_compare_array'
require 'hashdiff/diff'
require 'hashdiff/patch'
require 'hashdiff/version'

HashDiff = Hashdiff

warn 'The HashDiff constant used by this gem conflicts with another gem of a similar name.  As of version 1.0 the HashDiff constant will be completely removed and replaced by Hashdiff.  For more information see https://github.com/liufengyun/hashdiff/issues/45.'
