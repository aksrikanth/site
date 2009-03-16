class StaticFilesController < ApplicationController
  STATIC_DIR = "#{RAILS_ROOT}/public/static/"

  def show
    path = params[:id]
    if template_exists?(STATIC_DIR + path + '.html.haml')
      @file = STATIC_DIR + path + '.html.haml'
    end
  end
end
