module DeleteResourceRoute
  def resources(*args, &block)
    super(*args) do
      yield if block_given?
      member do
        get :delete # 会调用application下的delete view
        delete :delete, action: :destroy
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send(:include, DeleteResourceRoute)


# <%= form_tag request.url, html: {method: :delete} do %>
#   <h2>Are you sure you want to delete this record?</h2>
#   <p>
#     <%= submit_tag "Destroy" %>
#       <% if request.referrer.present? %>
#         or <%= link_to "cancel", request.referer %>
#       <% end %>
#   </p>
# <% end %>
