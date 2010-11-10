module PlotChart
  # This function will draw a plot graph using all the registered series.
  # Giving only the data & data_description structure will draw the basic plot graph,
  # You can specify the radius ( external & internal ) of the plots.
  # You can also specify the color of the points ( will be unique in case of multiple series ).
  # Setting Shadow to true will draw a shadow under the plots.

  def draw_plot_graph(data,data_description,big_radius=5,small_radius=2,r2=-1,g2=-1,b2=-1,shadow=false)
    #/* Validate the Data and data_description array */
    data_description = self.validate_data_description("draw_plot_graph",data_description)
    self.validate_data("draw_plot_graph",data)
    graph_id = 0
    ro = r2
    go = g2
    bo = b2
    id =0
    color_id =0
    data_description["values"].each do |col_name|
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end
      r = @palette[color_id]["r"]
      g = @palette[color_id]["g"]
      b = @palette[color_id]["b"]
      r2 = ro
      g2 = go
      b2 = bo
      #TODO convert this function
      im_symbol =""
      if ( !data_description["symbol"].nil? && !data_description["symbol"][col_name].nil?)
        is_alpha = false # ((ord ( file_get_contents (data_description["symbol"][col_name], false, NULL, 25, 1)) & 6) & 4) == 4
        im_symbol      = image_create_from_png(data_description["symbol"][col_name])
        infos       = get_image_size(im_symbol)
        image_width  = infos[0]
        image_height = infos[1]
        #
      end

      x_pos  = @g_area_x1 + @g_area_x_offset
      h_size = (big_radius/2).round
      r3 = -1
      g3 = -1
      b3 = -1
      data.each do |key|
        value= key[col_name]
        if value.is_a?(Numeric)
          y_pos  = @g_area_y2 - ((value-@vmin) * @division_ratio)
        else
          y_pos  = @g_area_y2 - ((0-@vmin) * @division_ratio)
        end


        #  Save point into the image map if option activated
        if ( @build_map )
          #add_to_image_map(x_pos-h_size,y_pos-h_size,x_pos+1+h_size,y_pos+h_size+1,data_description["description"][col_name],key[col_name].data_description["unit"]["y"],"Plot")
        end

        if(value.is_a?(Numeric))
          #MY Hack
          if (data_description["symbol"].nil? || data_description["symbol"][col_name].nil? )
            if ( shadow )
              if ( r3 !=-1 && g3 !=-1 && b3 !=-1 )
                self.draw_filled_circle(x_pos+2,y_pos+2,big_radius,r3,g3,b3)
              else
                r3 = @palette[color_id]["r"]-20
                r3 = 0 if ( r3 < 0 )
                g3 = @palette[color_id]["g"]-20
                g3 = 0 if ( g3 < 0 )
                b3 = @palette[color_id]["b"]-20
                b3 = 0 if ( b3 < 0 )
                self.draw_filled_circle(x_pos+2,y_pos+2,big_radius,r3,g3,b3)
              end
            end
            self.draw_filled_circle(x_pos+1,y_pos+1,big_radius,r,g,b)
            if ( small_radius != 0 )
              if ( r2 !=-1 && g2 !=-1 && b2 !=-1 )
                self.draw_filled_circle(x_pos+1,y_pos+1,small_radius,r2,g2,b2)
              else
                r2 = @palette[color_id]["r"]-15
                r2 = 0 if ( r2 < 0 )
                g2 = @palette[color_id]["g"]-15
                g2 = 0 if ( g2 < 0 )
                b2 = @palette[color_id]["b"]-15
                b2 = 0 if ( b2 < 0 )
                self.draw_filled_circle(x_pos+1,y_pos+1,small_radius,r2,g2,b2)
              end
            end
          else
            image_copy_merge(im_symbol,@picture,x_pos+1-image_width/2,y_pos+1-image_height/2,0,0,image_width,image_height,100)

          end
        end
        x_pos = x_pos + @division_width
      end
      graph_id+=1
    end
  end

  # This function is very similar as the draw_plot_graph function.
  # You must specify the name of the two series that will be used as x and y coordinates and the color id to use.

  def draw_xy_plot_graph(data,data_description,y_serie_name,x_serie_name,palette_id=0,big_radius=5,small_radius=2,r2=-1,g2=-1,b2=-1,shadow=true)
    r = @palette[palette_id]["r"]
    g = @palette[palette_id]["g"]
    b = @palette[palette_id]["b"]
    r3 = -1
    g3 = -1
    b3 = -1

    y_last = -1
    x_last = -1
    data.each do |key|
      if (!key[y_serie_name].nil? && !key[x_serie_name])
        x = key[x_serie_name]
        y = key[y_serie_name]
        y = @g_area_y2 - ((y-@vmin) * @division_ratio)
        x = @g_area_x1 + ((x-@v_x_min) * @x_division_ratio)
        if ( shadow )
          if ( r3 !=-1 && g3 !=-1 && b3 !=-1 )
            self.draw_filled_circle(x+2,y+2,big_radius,r3,g3,b3)
          else
            r3 = @palette[palette_id]["r"]-20
            r = 0 if ( r < 0 )
            g3 = @palette[palette_id]["g"]-20
            g = 0 if ( g < 0 )
            b3 = @palette[palette_id]["b"]-20
            b = 0  if ( b < 0 )
            draw_filled_circle(x+2,y+2,big_radius,r3,g3,b3)
          end
        end
        draw_filled_circle(x+1,y+1,big_radius,r,g,b)

        if ( r2 !=-1 && g2 !=-1 && b2 !=-1 )
          draw_filled_circle(x+1,y+1,small_radius,r2,g2,b2)
        else
          r2 = @palette[palette_id]["r"]+20
          r = 255 if ( r > 255 )
          g2 = @palette[palette_id]["g"]+20
          g = 255 if ( g > 255 )
          b2 = @palette[palette_id]["b"]+20
          b = 255 if ( b > 255 )
          draw_filled_circle(x+1,y+1,small_radius,r2,g2,b2)
        end
      end
    end
  end
  def draw_limits_graph(data,data_description,r=0,g=0,b=0)
    data_description = self.validate_data_description("draw_limits_graph",data_description)
    self.validate_data("draw_limits_graph",data)
    x_width = @division_width / 4
    xpos   = @g_area_x1 + @g_area_x_offset
    data.each do	 |key|
      min     = key[data_description["values"][0]]
      max     = key[data_description["values"][0]]
      graph_id = 0
      max_id = 0
      min_id = 0
      data_description["values"].each do |col_name|
        if (!key[col_name].nil?)
          if ( key[col_name] > max && key[col_name].is_a?(Numeric))
            max = key[col_name]
            max_id = graph_id
          end
        end
        if ( !key[col_name].nil? && key[col_name].is_a?(Numeric))
          if ( key[col_name] < min )
            min = key[col_name]
            min_id = graph_id
          end
          graph_id+=1
        end
      end

      ypos = @g_area_y2 - ((max-@vmin) * @division_ratio)
      x1 = (xpos - x_width).floor
      y1 = (ypos).floor - 0.2
      x2 = (xpos + x_width).floor
      x1 = @g_area_x1 + 1 if ( x1 <= @g_area_x1 )
      x2 = @g_area_x2 - 1 if ( x2 >= @g_area_x2 )
      ypos = @g_area_y2 - ((min-@vmin) * @division_ratio)
      y2 = ypos.floor + 0.2
      draw_line(xpos.floor-0.2,y1+1,xpos.floor-0.2,y2-1,r,g,b,true)
      draw_line(xpos.floor+0.2,y1+1,xpos.floor+0.2,y2-1,r,g,b,true)
      draw_line(x1,y1,x2,y1,@palette[max_id]["r"],@palette[max_id]["g"],@palette[max_id]["b"],false)
      draw_line(x1,y2,x2,y2,@palette[min_id]["r"],@palette[min_id]["g"],@palette[min_id]["b"],false)
      xpos = xpos + @division_width
    end
  end
end
