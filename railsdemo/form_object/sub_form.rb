class SubForm
  include ActiveModel::Validations

  attr_reader :association_name, :parent, :model, :name

  def initialize(args)
    @association_name = args[:assoc_name]
    @parent = args[:parent]
    @model = build_model
    self.class_eval &args[:proc]
  end

  def submit(params)
    model.attributes = params
  end

  def valid?
    super
    model.valid?
    collect_errors_from(model)
    errors.empty?
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        model.save
      end
    else
      false
    end
  end

  def persisted?
    model.persisted?
  end

  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    alias_method :attribute, :attributes
  end

  private

  def build_model
    if parent.send("#{association_name}")
      model = parent.send("#{association_name}")
    else
      model_class = association_name.to_s.camelize.constantize
      model = model_class.new
      parent.send("#{association_name}=", model)
    end
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end
end
