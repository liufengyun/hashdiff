# frozen_string_literal: true

module Hashdiff
  # @private
  # Used to compare arrays using the lcs algorithm
  class LcsCompareArrays
    class << self
      def call(obj1, obj2, opts = {})
        result = []

        changeset = Hashdiff.diff_array_lcs(obj1, obj2, opts) do |lcs|
          # use a's index for similarity
          lcs.each do |pair|
            prefix = Hashdiff.prefix_append_array_index(opts[:prefix], pair[0], opts)

            result.concat(Hashdiff.diff(obj1[pair[0]], obj2[pair[1]], opts.merge(prefix: prefix)))
          end
        end

        changeset.each do |change|
          next if change[0] != '-' && change[0] != '+'

          change_key = Hashdiff.prefix_append_array_index(opts[:prefix], change[1], opts)

          result << [change[0], change_key, change[2]]
        end

        combine_replacements(result)
      end

      private

      # LCS identifies items that remain in the array. A removal and an
      # addition at the same index therefore represent a replacement.
      def combine_replacements(changes)
        additions = {}
        changes.each_with_index do |change, index|
          additions[change[1]] = index if change[0] == '+'
        end

        replacements = {}
        changes.each_with_index do |change, index|
          replacements[index] = additions[change[1]] if change[0] == '-' && additions.key?(change[1])
        end

        replaced_additions = replacements.each_value.each_with_object({}) do |index, additions_to_skip|
          additions_to_skip[index] = true
        end

        combined = []
        changes.each_with_index do |change, index|
          if (replacement_index = replacements[index])
            replacement = changes[replacement_index]
            combined << ['~', change[1], change[2], replacement[2]]
          elsif replaced_additions.key?(index)
            next
          else
            combined << change
          end
        end

        combined
      end
    end
  end
end
