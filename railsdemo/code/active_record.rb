# Robust JSON output for active record errors
#
# See https://groups.google.com/forum/#!topic/rubyonrails-core/hxgX6D9s2uM
module ActiveRecord
  module AutosaveAssociation
    def validate_collection_association(reflection)
      if association = association_instance_get(reflection.name)
        if records = associated_records_to_validate_or_save(association, new_record?, reflection.options[:autosave])
          records.each_with_index do |record, index|
            association_valid?(reflection, record, index)
          end
        end
      end
    end

    def association_valid?(reflection, record, index = nil)
      return true if record.destroyed? || record.marked_for_destruction?

      unless valid = record.valid?
        if reflection.options[:autosave]
          association_errors = if errors.has_key?(reflection.name.to_s)
                                 errors[reflection.name.to_s]
                               else
                                 errors[reflection.name.to_s] = {}
                               end

          if index
            association_errors = association_errors[index] ||= {}
          end

          record.errors.each do |attribute, message|
            association_errors[attribute] ||= []
            association_errors[attribute] << message
          end
        else
          errors.add(reflection.name)
        end
      end
      valid
    end
  end
end

# after json
{
    "employments": {
        "0": { "company": ["can't be blank"] },
        "1": { "company": ["can't be blank"] }
    },
    "email": ["can't be blank"],
    "password": ["can't be blank"]
}

# before json
{
    "employments.company": ["can't be blank"],
    "email": ["can't be blank"],
    "password": ["can't be blank"]
}