# frozen_string_literal: true

module Hashdiff
  # @private
  # Used to compare hashes
  class CompareHashes
    class << self
      def call(obj1, obj2, opts = {})
        return [] if obj1.empty? && obj2.empty?

        obj1_keys = obj1.keys
        obj2_keys = obj2.keys

        added_keys = (obj2_keys - obj1_keys).sort_by(&:to_s)
        common_keys = (obj1_keys & obj2_keys).sort_by(&:to_s)
        deleted_keys = (obj1_keys - obj2_keys).sort_by(&:to_s)

        result = []

        # add deleted properties
        deleted_keys.each do |k|
          change_key = Hashdiff.prefix_append_key(opts[:prefix], k, opts)
          custom_result = Hashdiff.custom_compare(opts[:comparison], change_key, obj1[k], nil)

          if custom_result
            result.concat(custom_result)
          else
            result << ['-', change_key, obj1[k]]
          end
        end

        # recursive comparison for common keys
        common_keys.each do |k|
          prefix = Hashdiff.prefix_append_key(opts[:prefix], k, opts)

          result.concat(Hashdiff.diff(obj1[k], obj2[k], opts.merge(prefix: prefix)))
        end

        # added properties
        added_keys.each do |k|
          change_key = Hashdiff.prefix_append_key(opts[:prefix], k, opts)

          custom_result = Hashdiff.custom_compare(opts[:comparison], change_key, nil, obj2[k])

          if custom_result
            result.concat(custom_result)
          else
            result << ['+', change_key, obj2[k]]
          end
        end

        result
      end
    end
  end
end
