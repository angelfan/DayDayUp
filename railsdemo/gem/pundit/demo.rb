class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
end

class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def update?
    user.admin? || !post.published?
  end
end

class PostPolicy < ApplicationPolicy
  def update?
    user.admin? || !record.published?
  end
end

def update
  @post = Post.find(params[:id])
  authorize @post
  if @post.update(post_params)
    redirect_to @post
  else
    render :edit
  end
end

def publish
  @post = Post.find(params[:id])
  # 相当于执行authorize(record, query=update?)
  authorize @post, :update?
  @post.publish!
  redirect_to @post
end
