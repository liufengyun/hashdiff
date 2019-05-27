# frozen_string_literal: true

require_relative 'hashdiff/util'
require_relative 'hashdiff/compare_hashes'
require_relative 'hashdiff/lcs'
require_relative 'hashdiff/lcs_compare_arrays'
require_relative 'hashdiff/linear_compare_array'
require_relative 'hashdiff/diff'
require_relative 'hashdiff/patch'
require_relative 'hashdiff/version'

HashDiff = Hashdiff

warn 'The HashDiff constant used by this gem conflicts with another gem of a similar name.  As of version 1.0 the HashDiff constant will be completely removed and replaced by Hashdiff.  For more information see https://github.com/liufengyun/hashdiff/issues/45.'
