module LineChart
  # This function will draw a line graph using all the registered series.
  def draw_line_graph(data,data_description,serie_name="")
    data_description = self.validate_data_description("draw_line_graph",data_description)
    self.validate_data("draw_line_graph",data)
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
      if ( serie_name == "" || serie_name == col_name )
        x_pos  = @g_area_x1 + @g_area_x_offset
        x_last = -1
        y_last = -1
        data.each do |key|
          if(!key[col_name].nil?)
            value = key[col_name]
            if(value.is_a?(Numeric))
              y_pos= @g_area_y2 - ((value-@vmin) * @division_ratio)
            else
              y_pos= @g_area_y2 - ((0-@vmin) * @division_ratio)
            end
            # /* Save point into the image map if option activated */
            if ( @build_map )
              #self.add_to_image_map(x_pos-3,y_pos-3,x_pos+3,y_pos+3,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"Line")
            end
            x_last = -1 if(!value.is_a?(Numeric))
            if ( x_last != -1 )
              self.draw_line(x_last,y_last,x_pos,y_pos,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true)
            end
            x_last = x_pos
            y_last = y_pos
            x_last = -1 if(!value.is_a?(Numeric))
          end
          x_pos = x_pos + @division_width
        end
        graph_id+=1
      end
    end
  end
# This function will draw a filled line graph using all the registered series.
  # You can provide the alpha value used when merging all series layers.
  # If around_zero is set to true, the area drawn will be between the 0 axis and the line graph value.

  def draw_filled_line_graph(data,data_description,alpha=100,around_zero=false)
    empty = -2147483647
    data_description = self.validate_data_description("draw_filled_line_graph",data_description)
    self.validate_data("draw_filled_line_graph",data)
    layer_width  = @g_area_x2-@g_area_x1
    layer_height = @g_area_y2-@g_area_y1
    graph_id = 0
    id =0
    color_id =0
    data_description["values"].each do |col_name|
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end

      a_points   = []
      a_points << @g_area_x_offset
      a_points << layer_height
      @layers[0] = image_create_true_color(layer_width,layer_height)
      c_white         = allocate_color(@layers[0],255,255,255)
      image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
      image_color_transparent(@layers[0],255,255,255)

      xpos  = @g_area_x_offset
      xlast = -1
      points_count = 2
      y_zero = layer_height - ((0-@vmin) * @division_ratio)
      y_zero = layer_height if ( y_zero > layer_height )
      ylast = empty

      data.each do |key|
        value = key[col_name]
        if key[col_name].is_a?(Numeric)
          ypos = layer_height - ((value-@vmin) * @division_ratio)
        else
          ypos = layer_height - ((0-@vmin) * @division_ratio)
        end
        #   Save point into the image map if option activated */
        if ( @build_map )
          #self.add_to_image_map(xpos-3,ypos-3,xpos+3,ypos+3,data_description["description"][col_name],key[col_name].data_description["unit"]["Y"],"FLine")
        end
        if ( !(value.is_a?(Numeric)))
          points_count+=1
          a_points << xlast
          a_points << layer_height
          ylast = empty
        else
          points_count+=1
          if ( ylast != empty )
            a_points << xpos
            a_points << ypos
          else
            points_count+=1
            a_points << xpos
            a_points << layer_height
            a_points << xpos
            a_points <<  ypos
          end

          if (ylast !=empty && around_zero)
            points   = []
            points << xlast
            points << ylast
            points << xpos
            points << ypos
            points << xpos
            points << y_zero
            points << xlast
            points << y_zero
            c_graph = allocate_color(@layers[0],@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"])
            image_filled_polygon(@layers[0],points,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],4)
          end
          ylast = ypos
        end
        xlast = xpos
        xpos  = xpos + @division_width
      end

      a_points << layer_width - @g_area_x_offset
      a_points << layer_height

      if ( around_zero == false )
        c_graph = allocate_color(@layers[0],@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"])
        image_filled_polygon(@layers[0],a_points,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],points_count)
      end

      image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
      image_destroy(@layers[0])
      graph_id+=1
      draw_line_graph(data,data_description,col_name)
    end
  end
  # This function will draw a scatter line graph.
  # You must specify the x and y series that will be used.
  # You can optionaly set the color index in the current palette.
  def draw_xy_graph(data,data_description,y_serie_name,x_serie_name,palette_id=0)
    y_last = -1
    x_last = -1
    data.each do |key|
      if ( !key[y_serie_name].nil? && !key[x_serie_name].nil? )
        x= key[x_serie_name]
        y = key[y_serie_name]
        y = @g_area_y2 - ((y-@vmin) * @division_ratio)
        x=  @g_area_x1 + ((x-@v_x_min) * @x_division_ratio)
        if (x_last != -1 && y_last != -1)
          draw_line(x_last,y_last,x,y,@palette[palette_id]["r"],@palette[palette_id]["g"],@palette[palette_id]["b"],true)
        end
        x_last = x
        y_last = y
      end
    end
  end
end
