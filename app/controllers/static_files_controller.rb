class StaticFilesController < ApplicationController
  STATIC_DIR = "#{RAILS_ROOT}/public/static/"
  STATIC_EXT = '.html.haml'

  def index
    if template_exists? path = STATIC_DIR + params[:path].join('/') + STATIC_EXT
      render :file => path, :layout => true
    else
      render :text => 'Nothing to see here', :layout => true
    end
  end

  private
  # Define template_exists? for Rails 2.3 (cause it's deprecated)
  unless ActionController::Base.private_instance_methods.include? 'template_exists?'
    def template_exists?(path)
      self.view_paths.find_template(path, response.template.template_format)
    rescue ActionView::MissingTemplate
      false
    end
  end

end
