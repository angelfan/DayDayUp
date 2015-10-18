class Product < ActiveRecord::Base
  belongs_to :category
  has_many :taggings
  has_many :tags, through: :taggings

  attr_writer :tag_names
  attr_accessor :new_category

  before_save :create_category
  before_save :save_tag_names

  def create_category
    self.category = Category.create!(name: new_category) if new_category.present?
  end

  def tag_names
    @tag_names || tags.pluck(:name).join(' ')
  end

  def save_tag_names
    if @tag_names
      self.tags = @tag_names.split.map { |name| Tag.where(name: name).first_or_create! }
    end
  end
end

# 增加虚拟属性， 方便交给callback去做回调处理
#  如果不增加虚拟属性， 就要变成controller调用model的实例方法，并传入相关参数
# 比如：
class PagesController < ApplicationController
  def update
    @product = Product.find(params[:id])
    @product.save_tag_names(params[:tag_names])
  end
end
# 远不如增加虚拟属性用回调来处理显得漂亮
