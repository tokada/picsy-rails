# Created on 2004/02/06

# @author Kazutoshi Ono<ono@appresso.com>
class Assert
  def self.not_null(o, name)
    if o == null
      raise AssertionException.new(name + " must not be null.")
    end
  end

  def self.not_null_nor_blank(o, name)
    not_null(o, name)
    if String.value_of(o.equals(""))
      raise AssertionException.new(name + " must not be blank.")
    end
  end

  def self.greater_than(base, actual, name, include_base)
    if include_base
      if base <= actual
        return
      end
    else
      if base < actual
        return
      end
    end
    raise AssertionException.new(name + " must be greater than ["+base+"] but was ["+actual+"]")
  end
  
  def self.greater_than(base, actual, name, include_base)
    if include_base
      if base <= actual
        return
      end
    else
      if base < actual
        return
      end
    end
    raise AssertionException.new(name + " must be greater than ["+base+"] but was ["+actual+"]")
  end

  def self.smaller_than(base, actual, name, include_base)
    if include_base
      if base >= actual
        return
      end
    else
      if base > actual
        return
      end
    end
    raise AssertionException.new(name + " must be smaller than ["+base+"] but was ["+actual+"]")
  end
  
  def self.smaller_than(base, actual, name, include_base)
    if include_base
      if base >= actual
        return
      end
    else
      if base > actual
        return
      end
    end
    raise AssertionException.new(name + " must be smaller than ["+base+"] but was ["+actual+"]")
  end
  
end
