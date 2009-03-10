module HamlHelper

  def rounded_box(type, options = {})
    table_class = "rounded-box #{type}-rounded-box".strip
    haml_tag :table, :summary => '', :class => table_class do
      haml_tag :tbody do
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-nw #{type}-rounded-box-corner"
          haml_tag :td, :class => "#{type}-rounded-box-n"
          if options[:flush_guard]
            haml_tag :td, :class => "#{type}-rounded-box-e", :rowspan => 2 do
              haml_tag :div, :class => "#{type}-rounded-box-ne #{type}-rounded-box-corner"
            end
          else
            haml_tag :td, :class => "#{type}-rounded-box-ne #{type}-rounded-box-corner"
          end
        end
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-w"
          haml_tag :td, :class => "#{type}-rounded-box-content-cell" do
            haml_tag :div, :class => "#{type}-rounded-box-content" do
              yield
            end
          end
          haml_tag :td, :class => "#{type}-rounded-box-e" unless options[:flush_guard]
        end
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-sw #{type}-rounded-box-corner"
          haml_tag :td, :class => "#{type}-rounded-box-s"
          haml_tag :td, :class => "#{type}-rounded-box-se #{type}-rounded-box-corner"
        end
      end
    end
  end

end
