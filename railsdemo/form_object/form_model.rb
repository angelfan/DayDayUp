class FormModel
  include ActiveModel::Model

  attr_reader :model, :forms

  def initialize(model)
    @model = model
    @forms = []
    populate_forms
  end

  def submit(params)
    model.attributes = params_for_main_model(params)
    nested_params = params_for_nested_models(params)

    nested_params.each do |association|
      assign_to(association)
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        model.save
        forms.each(&:save)
      end
    else
      false
    end
  end

  def valid?
    super
    model.valid?
    collect_errors_from(model)
    collect_forms_errors
    errors.empty?
  end

  def persisted?
    model.persisted?
  end

  def to_key
    return nil unless persisted?
    model.id
  end

  def to_param
    return nil unless persisted?
    model.id.to_s
  end

  def to_partial_path
    ''
  end

  def to_model
    model
  end

  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    def association(name, &block)
      forms << { assoc_name: name, proc: block }
      attr_reader name
    end

    def forms
      @forms ||= []
    end
  end

  private

  def populate_forms
    self.class.forms.each do |definition|
      definition[:parent] = model
      sub_form = SubForm.new(definition)
      forms << sub_form
      instance_variable_set("@#{definition[:assoc_name]}", sub_form)
    end
  end

  def params_for_main_model(params)
    params.reject { |_key, value| value.is_a?(Hash) }
  end

  def params_for_nested_models(params)
    params.select { |_key, value| value.is_a?(Hash) }
  end

  def assign_to(association)
    assoc_name = association.first
    forms.each do |form|
      if form.association_name.to_s == assoc_name.to_s
        form.submit(association.last)
      end
    end
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end

  def collect_forms_errors
    forms.each do |form|
      form.valid?
      form.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
  end
end
