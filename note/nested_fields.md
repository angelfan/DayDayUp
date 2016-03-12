# nested fields
```ruby
class Room < ActiveRecord::Base
    has_many :groups
    accepts_nested_attributes_for :groups
end
```

```ruby
# app/helpers/application_helper.rb
def link_to_add_fields(name, f, association, options = {})
    class_name = options.delete(:class) || 'btn btn-sm btn-success'
    new_object = f.object.send(association).klass.new
    id = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end

    link_to(name, '#', class: "#{class_name} add_fields", data: { id: id, fields: fields.delete("\n") })
end
````

```ruby
# view
= simple_form_for @Room do |f|
    = link_to_add_fields "增加", f, :groups
    #groups_fields
    = f.simple_fields_for :groups do |builder|
      = render 'group_fields', f: builder

# group_fields.html.slim
.group_fields
    = f.input :attribute

    = f.hidden_field :_destroy
    = link_to '删除', '#', class: 'remove_fields'
```

```javascript
jQuery ->
    $('form').on 'click', '.remove_fields', (event) ->
      $(this).prev('input[type=hidden]').val('1')
      $(this).closest('.tag_fields').hide()
      event.preventDefault()

    $('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $('#tags_fields').append($(this).data('fields').replace(regexp, time))
      event.preventDefault()
```