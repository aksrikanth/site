class ArticlesController < ApplicationController
  def show
    template = 'articles/posts/' + params[:title]
    if template_exists? template
      render :template => template
    else
      raise ::ActionController::RoutingError,
        "Recognition failed for #{request.path.inspect}"
    end
  end

  def index
    @articles = []
    @short = true
    Dir.chdir('app/views/articles/posts/') do
      files = Dir.glob('[^_]*.html.haml')

      @articles = files.map do |file|
        {
          :basename => file.gsub(/.html.haml$/, ''),
          :time => File.mtime(file),
        }
      end
      @articles.sort do |a, b|
        b[:time] <=> a[:time]
      end
    end
  end
end
