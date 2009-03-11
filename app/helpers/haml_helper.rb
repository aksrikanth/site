module HamlHelper

  def rounded_box(type, options = {})
    table_class = "rounded-box #{type}-rounded-box".strip
    haml_tag :table, :summary => '', :class => table_class do
      haml_tag :tbody do
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-nw #{type}-rounded-box-corner"
          haml_tag :td, :class => "#{type}-rounded-box-n"
          haml_tag :td, :class => "#{type}-rounded-box-ne #{type}-rounded-box-corner"
        end
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-w"
          haml_tag :td, :class => "#{type}-rounded-box-content-cell" do
            haml_tag :div, :class => "#{type}-rounded-box-content" do
              yield
            end
          end
          haml_tag :td, :class => "#{type}-rounded-box-e"
        end
        haml_tag :tr do
          haml_tag :td, :class => "#{type}-rounded-box-sw #{type}-rounded-box-corner"
          haml_tag :td, :class => "#{type}-rounded-box-s"
          haml_tag :td, :class => "#{type}-rounded-box-se #{type}-rounded-box-corner"
        end
      end
    end
  end

  def layout_column_boxes(type, columns)
    table_class = "rounded-box #{type}-rounded-box".strip
    haml_tag :table, :summary => '', :class => table_class do
      haml_tag :tbody do
        haml_tag :tr do
          (0...columns.length).each do |i|
            haml_tag :td, :class => "#{type}-rounded-box-gap" unless i == 0
            haml_tag :td, :class => "#{type}-rounded-box-nw #{type}-rounded-box-corner"
            haml_tag :td, :class => "#{type}-rounded-box-n"
            haml_tag :td, :class => "#{type}-rounded-box-ne #{type}-rounded-box-corner"
          end
        end
        haml_tag :tr do
          (0...columns.length).each do |i|
            haml_tag :td, :class => "#{type}-rounded-box-gap" unless i == 0
            haml_tag :td, :class => "#{type}-rounded-box-w"
            haml_tag :td, :class => "#{type}-rounded-box-content-cell", :id => columns[i][:id] do
              haml_tag :div, :class => "#{type}-rounded-box-content" do
                if columns[i][:yield]
                  yield
                else
                  concat render(:partial => columns[i][:partial], :locals => columns[i][:locals])
                end
              end
            end
            haml_tag :td, :class => "#{type}-rounded-box-e"
          end
        end
        haml_tag :tr do
          (0...columns.length).each do |i|
            haml_tag :td, :class => "#{type}-rounded-box-gap" unless i == 0
            haml_tag :td, :class => "#{type}-rounded-box-sw #{type}-rounded-box-corner"
            haml_tag :td, :class => "#{type}-rounded-box-s"
            haml_tag :td, :class => "#{type}-rounded-box-se #{type}-rounded-box-corner"
          end
        end
      end
    end
  end

end
