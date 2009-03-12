class ArticlesController < ApplicationController
  before_filter :load_posts

  POSTS_DIR = "#{RAILS_ROOT}/app/views/articles/posts/"
  POSTS_FILE = "#{POSTS_DIR}posts.yml"

  def load_posts
    @posts = YAML::load(File.open(POSTS_FILE))
  end

  def show
    @post = nil
    @posts.each do |post|
      @post = post if post[:id].to_s == params[:id]
    end
    @posts_dir = POSTS_DIR
  end

  def index
    @articles = @posts.sort do |a, b|
      b[:time] <=> a[:time]
    end
  end
end
