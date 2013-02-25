class ArticlesController < ApplicationController
  before_filter :load_posts

  cattr_accessor :mtime
  cattr_accessor :articles

  def show
    @article = articles.select { |a| a[:id].to_s == params[:id].to_s }.first
  end

  def index
    @articles = articles
    respond_to do |format|
      format.atom
      format.html
    end
  end

protected

  def load_posts
    config = Site.configuration
    filename = ::Rails.root.join(config[:posts_dir], config[:posts_file])
    if mtime.blank? || File.mtime(filename) > mtime
      self.mtime = File.mtime(filename)
      self.articles = YAML::load(File.open(filename)).sort do |a, b|
        b[:time] <=> a[:time]
      end
    end
    articles
  end

end
