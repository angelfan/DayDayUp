class User < ActiveRecord::Base
  has_many :hobbies, dependent: :destroy

  accepts_nested_attributes_for :hobbies
end

User.create(name: 'Stan',
            hobbies_attributes: [{ name: 'Water skiing' },
                                 { name: 'Hiking' }])

class Product
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  embeds_one :pricing
end

class Pricing
  include Mongoid::Document

  field :retail, type: Integer, default: 0
  field :sale, type: Integer, default: 0

  embedded_in :product
end

params.require(:product).permit(
  :slug, :sku, :name, :description,
  :total_reviews, :average_review, :main_cat_id,
  pricing: [:sale, :retail]
)
