module AttributeChecked
  def attr_checked(attr, &validate)

    define_method "#{attr}" do
      eval("@#{attr}")
    end

    define_method "#{attr}=" do |v|
      if validate
        raise 'Invalid attribute' unless validate.call(v)
      end
      eval("@#{attr} = v")
    end
  end
end



class Person
  extend AttributeChecked
  attr_checked :age do |v|
    v >= 18
  end

  attr_checked :name
end