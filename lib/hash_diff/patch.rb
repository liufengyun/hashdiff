# 
# This class provides methods to diff two hash, patch and unpatch hash
#
module HashDiff

  # apply changes to object
  #
  # changes: [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  def self.patch(hash, changes)
    changes.each do |change|
      parts = decode_property_path(change[1])
      last_part = parts.last

      dest_node = node(hash, parts[0, parts.size-1])

      if change[0] == '+'
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

    hash
  end

  # undo changes from object.
  #
  # changes: [[ '+', 'a.b', '45' ], [ '-', 'a.c', '5' ], [ '~', 'a.x', '45', '63']]
  def self.unpatch(hash, changes)
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
