# jquery ui autocomplete
# <%= f.text_field :category_name, data: {autocomplete_source: categories_path} %>
#
# jQuery ->
# $('#product_category_name').autocomplete
# source: $('#product_category_name').data('autocomplete-source')

# ul.ui-autocomplete {
#   position: absolute;
#   list-style: none;
#   margin: 0;
#   padding: 0;
#   border: solid 1px #999;
#   cursor: default;
#   li {
#     background-color: #FFF;
#         border-top: solid 1px #DDD;
#     margin: 0;
#     padding: 0;
#     a {
#       color: #000;
#           display: block;
#       padding: 3px;
#     }
#     a.ui-state-hover, a.ui-state-active {
#       background-color: #FFFCB2;
#     }
#   }
# }

class CategoriesController < ApplicationController
  def index
    @categories = Category.order(:name).where("name like ?", "%#{params[:term]}%")
    render json: @categories.map(&:name)
  end
end
