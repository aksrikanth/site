module HamlHelper

  def rounded_box(type, options = {})
    haml_tag :table, :summary => '', :class => "rounded-box #{type}-rounded-box" do
      if type == 'sidebar'
        haml_tag :tfoot do
          haml_tag :tr do
            haml_tag :td, '&nbsp;', :colspan => 3
          end
        end
      end
      haml_tag :tbody do
        ['top', 'middle', 'bottom'].each do |vpos|
          haml_tag :tr, :class => vpos do
            ['left', 'center', 'right'].each do |hpos|
              if vpos == 'middle' and hpos == 'center'
                haml_tag :td, :class => 'content-cell' do
                  haml_tag :div, :class => 'content' do
                    if options[:callout]
                      haml_tag :div, :class => "callout callout-#{options[:callout]}"
                    end
                    yield
                  end
                end
              elsif vpos == 'middle' or hpos == 'center'
                haml_tag :td, :class => "#{hpos} edge"
              else
                haml_tag :td, :class => "#{hpos} corner"
              end
            end
          end
        end
      end
    end
  end

end
