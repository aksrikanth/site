class ArticlesController < ApplicationController
  before_filter :load_posts

  POSTS_DIR = "#{RAILS_ROOT}/app/views/articles/posts/"
  POSTS_FILE = "#{POSTS_DIR}posts.yml"

  def load_posts
    @posts = YAML::load(File.open(POSTS_FILE))
    @articles = @posts.sort do |a, b|
      b[:time] <=> a[:time]
    end
  end

  def show
    @article = nil
    @articles.each do |article|
      @article = article if article[:id].to_s == params[:id]
    end
    @posts_dir = POSTS_DIR
  end

  def index
    respond_to do |format|
      format.html
      format.atom
    end
  end
end
