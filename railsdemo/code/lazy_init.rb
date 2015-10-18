class Person
  def email
    @email ||= []
  end

  def assistant
    return @assistant if instance_variable_defined? :@assistant
    @assistant = User.find(id)
    # unless instance_variable_defined? :@assistant
    #   @assistant = User.find(self.id)
    # end
    # @assistant
  end
end
