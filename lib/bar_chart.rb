module BarChart
# This function will draw a bar graph using all the registered series.
  # When creating a bar graph, don't forget to set the with_margin parameter of the draw_scale function to true.
  # Setting shadow to true will draw a shadow behind each series, this will also slow down a bit the renderer engine.

  def draw_bar_graph(data,data_description,shadow=false,alpha=100)
    data_description = self.validate_data_description("drawBarGraph",data_description)
    validate_data("drawBarGraph",data)

   # graph_id      = 0
    series       = (data_description["values"]).count
    series_width  = @division_width / (series+1)
    serie_x_offset = @division_width / 2 - series_width / 2

    y_zero  = @g_area_y2 - ((0-@vmin) * @division_ratio)
    y_zero = @g_area_y2 if ( y_zero> @g_area_y2 )
    serie_id = 0
    color_id =0
    id = 0
    data_description["values"].each do |col_name|
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end
      x_pos = @g_area_x1 + @g_area_x_offset - serie_x_offset + series_width * serie_id
    #  x_last = -1
      data.each do |key|
        if ( !key[col_name].nil?)
          if ( key[col_name].is_a?(Numeric) )
            value = key[col_name]
            y_pos = @g_area_y2 - ((value-@vmin) * @division_ratio)
            #  Save point into the image map if option activated */
            if (@build_map )
              #add_to_image_map(x_pos+1,[y_zero,y_pos].min,x_pos+series_width-1,[y_zero,y_pos].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"Bar")
            end
            if ( shadow && alpha == 100 )
              draw_rectangle(x_pos+1,y_zero,x_pos+series_width-1,y_pos,25,25,25)
            end
            draw_filled_rectangle(x_pos+1,y_zero,x_pos+series_width-1,y_pos,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true,alpha)
          end
          x_pos = x_pos + @division_width
        end
      end
      serie_id = serie_id+1
    end
  end

  # This function will draw a stacked bar graph using all the registered series.
  # When creating a bar graph, don't forget to set the with_margin parameter of the draw_scale function to true.
  # Don't forget to change the automatic scaling to Rchart::SCALE_ADDALL to have an accurate scaling mode.
  # You can specify the transparency and if the bars must be contiguous or with space (default)
  def draw_stacked_bar_graph(data,data_description,alpha=50,contiguous=false)
    # /* Validate the Data and data_description array */
    data_description = validate_data_description("draw_bar_graph",data_description)
    validate_data("draw_bar_graph",data)
    graph_id      = 0
    series       = (data_description["values"].count)
    if ( contiguous )
      series_width  = @division_width
    else
      series_width  = @division_width * 0.8
    end
    y_zero  = @g_area_y2 - ((0-@vmin) * @division_ratio)
    y_zero = @g_area_y2 if ( y_zero > @g_area_y2 )
    series_id = 0
    last_value = {}
    id = 0
    color_id = 0
    data_description["values"].each do |col_name|
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end
      x_pos  = @g_area_x1 + @g_area_x_offset - series_width / 2
      x_last = -1
      data.each do |key|
        if ( !key[col_name].nil?)
          if ( key[col_name].is_a?(Numeric) )
            value = key[col_name]
            if (!last_value[key].nil?)
              y_pos    = @g_area_y2 - (((value+last_value[key])-@vmin) * @division_ratio)
              y_bottom = @g_area_y2 - ((last_value[key]-@vmin) * @division_ratio)
              last_value[key] += value
            else
              y_pos    = @g_area_y2 - ((value-@vmin) * @division_ratio)
              y_bottom = y_zero
              last_value[key] = value
            end
            # Save point into the image map if option activated
            if ( @build_map )
              #add_to_image_map(x_pos+1,[y_bottom,y_pos].min,x_pos+series_width-1,[y_bottom,y_pos].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"sBar")
            end
            draw_filled_rectangle(x_pos+1,y_bottom,x_pos+series_width-1,y_pos,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true,alpha)
          end
        end
        x_pos = x_pos + @division_width
      end
      series_id+=1
    end
  end
  # This function will draw a superposed bar graph using all the registered series.
  # You can provide the alpha value used when merging all series layers.

  def draw_overlay_bar_graph(data,data_description,alpha=50)
    data_description = validate_data_description("draw_overlay_bar_graph",data_description)
    validate_data("draw_overlay_bar_graph",data)
    layer_width  = @g_area_x2-@g_area_x1
    layer_height = @g_area_y2-@g_area_y1
    graph_id = 0
    color_id =0
    id =0
    data_description["values"].each do |col_name|
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end
      @layers[graph_id] = image_create_true_color(layer_width,layer_height)
      image_filled_rectangle(@layers[graph_id],0,0,layer_width,layer_height,255,255,255)
      image_color_transparent(@layers[graph_id],255,255,255)
      x_width = @division_width / 4
      x_pos   = @g_area_x_offset
      y_zero  = layer_height - ((0-@vmin) * @division_ratio)
      x_last  = -1
      points_count = 2
      data.each do |key|
        if(!key[col_name].nil?)
          if(key[col_name].is_a?(Numeric))
            value = key[col_name]
            if (value.is_a?(Numeric) )
              y_pos  = layer_height - ((value-@vmin) * @division_ratio)
              image_filled_rectangle(@layers[graph_id],x_pos-x_width,y_pos,x_pos+x_width,y_zero,@palette[graph_id]["r"],@palette[graph_id]["g"],@palette[graph_id]["b"])
              x1 = (x_pos - x_width + @g_area_x1).floor
              y1 = (y_pos+@g_area_y1).floor + 0.2
              x2 = (x_pos + x_width + @g_area_x1).floor
              y2 = @g_area_y2 - ((0-@vmin) * @division_ratio)
              x1 = @g_area_x1 + 1 if ( x1 <= @g_area_x1 )
              x2 = @g_area_x2 - 1 if ( x2 >= @g_area_x2 )

              # Save point into the image map if option activated */
              if ( @build_map )
                #add_to_image_map(x1,[y1,y2].min,x2,[y1,y2].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"oBar")
              end
              draw_line(x1,y1,x2,y1,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true)
            end
          end
        end
        x_pos = x_pos + @division_width
      end
      graph_id+=1
    end
    i=0
    while (i<=(graph_id-1))
      image_copy_merge(@layers[i],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
      image_destroy(@layers[i])
      #	image_destroy(@layers[i])
      i=i+1
    end
  end

end
