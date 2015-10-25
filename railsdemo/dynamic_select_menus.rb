class Country < ActiveRecord::Base
  has_many :states
  has_many :people
end

class State < ActiveRecord::Base
  belongs_to :country
  has_many :people
end


# <%= form_for @person do |f| %>
#   <%= f.label :country_id %><br />
#   <%= f.collection_select :country_id, Country.order(:name), :id, :name, include_blank: true %>
#
#   <%= f.label :state_id, "State or Province" %><br />
#   <%= f.grouped_collection_select :state_id, Country.order(:name), :states, :name, :id, :name, include_blank: true %>
# <% end %>


# jQuery ->
# $('#person_state_id').parent().hide()
# states = $('#person_state_id').html()
# $('#person_country_id').change ->
# country = $('#person_country_id :selected').text()
# escaped_country = country.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
# options = $(states).filter("optgroup[label='#{escaped_country}']").html()
# if options
#   $('#person_state_id').html(options)
#   $('#person_state_id').parent().show()
# else
#   $('#person_state_id').empty()
#   $('#person_state_id').parent().hide()
