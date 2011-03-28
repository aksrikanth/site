# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def image_url(source)
    url = image_path(source)
    unless url =~ /^#{request.protocol}/
      url = "#{request.protocol}#{request.host_with_port}#{url}"
    end
    url
  end

end
