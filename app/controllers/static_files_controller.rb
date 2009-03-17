class StaticFilesController < ApplicationController
  STATIC_DIR = "#{RAILS_ROOT}/public/static/"

  def show
    path = params[:id]
    if template_exists?(STATIC_DIR + path + '.html.haml')
      @file = STATIC_DIR + path + '.html.haml'
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
