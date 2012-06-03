# 
# This module provides methods to diff two hash, patch and unpatch hash
#
module HashDiff

  # Apply patch to object
  #
  # @param [Hash, Array] obj the object to be patchted, can be an Array of a Hash
  # @param [Array] changes e.g. [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  #
  # @return the object after patch
  #
  # @since 0.0.1
  def self.patch!(obj, changes)
    changes.each do |change|
      parts = decode_property_path(change[1])
      last_part = parts.last

      dest_node = node(obj, parts[0, parts.size-1])

      if change[0] == '+'
        if dest_node == nil
          parent_key = parts[parts.size-2]
          parent_node = node(obj, parts[0, parts.size-2])
          if last_part.is_a?(Fixnum)
            dest_node = parent_node[parent_key] = []
          else
            dest_node = parent_node[parent_key] = {}
          end
        end

        if last_part.is_a?(Fixnum)
          dest_node.insert(last_part, change[2])
        else
          dest_node[last_part] = change[2]
        end
      elsif change[0] == '-'
        if last_part.is_a?(Fixnum)
          dest_node.delete_at(last_part)
        else
          dest_node.delete(last_part)
        end
      elsif change[0] == '~'
        dest_node[last_part] = change[3]
      end
    end

    obj
  end

  # Unpatch an object
  #
  # @param [Hash, Array] obj the object to be unpatchted, can be an Array of a Hash
  # @param [Array] changes e.g. [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  #
  # @return the object after unpatch
  #
  # @since 0.0.1
  def self.unpatch!(hash, changes)
    changes.reverse_each do |change|
      parts = decode_property_path(change[1])
      last_part = parts.last

      dest_node = node(hash, parts[0, parts.size-1])

      if change[0] == '+'
        if last_part.is_a?(Fixnum)
          dest_node.delete_at(last_part)
        else
          dest_node.delete(last_part)
        end
      elsif change[0] == '-'
        if dest_node == nil
          parent_key = parts[parts.size-2]
          parent_node = node(hash, parts[0, parts.size-2])
          if last_part.is_a?(Fixnum)
            dest_node = parent_node[parent_key] = []
          else
            dest_node = parent_node[parent_key] = {}
          end
        end

        if last_part.is_a?(Fixnum)
          dest_node.insert(last_part, change[2])
        else
          dest_node[last_part] = change[2]
        end
      elsif change[0] == '~'
        dest_node[last_part] = change[2]
      end
    end

    hash
  end

end
