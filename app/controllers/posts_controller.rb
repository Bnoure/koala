class PostsController < ApplicationController
  require 'news-api'
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
    # @comments = @post.comments
  end

  def more_posts
    index = params[:index].to_i
    @posts = Post.all.order(:created_at).offset(index).limit(6)
    render partial: 'post', collection: @posts, layout: false
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :url)
  end
end
