def find_class_name(subject)
  return nil if subject.nil?
  if subject.respond_to?(:model_name)
    subject.model_name.to_s
  elsif subject.class.respond_to?(:model_name)
    subject.class.model_name.to_s
  elsif subject.is_a?(Class)
    subject.to_s
  elsif subject.is_a?(Symbol)
    subject.to_s.camelize
  else
    subject.class
  end
end
