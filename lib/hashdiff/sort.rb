module HashDiff
  def self.sort(obj)
    return obj if obj.nil? || obj.is_a?(String)

    if obj.is_a?(Hash)
      newobj = {}
      obj.each do |key, value|
        newobj[key] = sort(value)
      end
      return newobj
    elsif obj.is_a?(Array) && obj.length > 0
      types_map = array_type(obj)
      unless types_map.keys.length <= 1
        fail 'cannot sort mixed type arrays ' + types_map.keys.to_s
      end

      type = types_map.keys.fetch(0)
      if type == "String"
        return obj.sort
      end

      newobj = []

      if type == "Hash"
        obj = obj.sort_by do |hash_element|
          hash_element.keys.first
        end
      end
      obj.each do |value|
        newobj.push(sort(value))
      end
      return newobj
    end

    obj
  end

  private
  
  def self.array_type(obj)
    type_map = {}
    obj.each do |e| 
      type = e.class.name
      unless type_map.key?(type)
        type_map[type] = 1
      end
    end
    type_map
  end
end
