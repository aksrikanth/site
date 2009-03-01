class ArticlesController < ApplicationController
  def show
    if template_exists? path = 'articles/' + params[:title]
      render :action => params[:title]
    else
      raise ::ActionController::RoutingError,
        "Recognition failed for #{request.path.inspect}"
    end
  end

  def index
    @articles = []
    @short = true
    Dir.chdir('app/views/articles/') do
      files = Dir.glob('[^_]*.html.haml')
      files.delete 'index.html.haml'

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
