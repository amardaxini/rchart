module Layout
  # A call to this function is mandatory when creating a graph.
  # The upper left and bottom right border positions are used as arguments.
  # This area will be used to draw graphs, grid, axis & more.
  # Calling this function will not draw anything this will only set the graph area boundaries.
  def set_graph_area(x1,y1,x2,y2)
    @g_area_x1 = x1
    @g_area_y1 = y1
    @g_area_x2 = x2
    @g_area_y2 = y2
  end
  # Prepare the graph area
  def draw_graph_area(r,g,b,stripe=false)
    draw_filled_rectangle(@g_area_x1,@g_area_y1,@g_area_x2,@g_area_y2,r,g,b,false)
    draw_rectangle(@g_area_x1,@g_area_y1,@g_area_x2,@g_area_y2,r-40,g-40,b-40)
    i=0
    if stripe
      r2 = r-15
      r2 = 0 if r2<0
      g2 = r-15
      g2 = 0  if g2 < 0
      b2 = r-15
      b2 = 0  if b2 < 0
      line_color = allocate_color(@picture,r2,g2,b2)
      skew_width = @g_area_y2-@g_area_y1-1

      i = @g_area_x1-skew_width

      while i.to_f<=@g_area_x2.to_f
        x1 = i
        y1 = @g_area_y2
        x2 = i+skew_width
        y2 = @g_area_y1
        if ( x1 < @g_area_x1 )
          x1 = @g_area_x1
          y1 = @g_area_y1 + x2 - @g_area_x1 + 1
        end
        if ( x2 >= @g_area_x2 )
          y2 = @g_area_y1 + x2 - @g_area_x2 +1
          x2 = @g_area_x2 - 1
        end
        image_line(@picture,x1,y1,x2,y2+1,r2,g2,b2)
        i = i+4
      end

    end
  end
  # This function will draw a grid over the graph area.
  # line_width will be passed to the draw_dotted_line function.
  # The r,g,b 3 parameters are used to set the grid color.
  # Setting mosaic to true will draw grey area between two lines.
  # You can define the transparency factor of the mosaic area playing with the alpha parameter.

  def draw_grid(line_width,mosaic=true,r=220,g=220,b=220,alpha=100)
    # Draw mosaic */
    if (mosaic)
      layer_width  = @g_area_x2-@g_area_x1
      layer_height = @g_area_y2-@g_area_y1

      @layers[0] = image_create_true_color(layer_width,layer_height)
      #c_white         = allocate_color(@layers[0],255,255,255)
      image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
      image_color_transparent(@layers[0],255,255,255)

      #c_rectangle =allocate_color(@layers[0],250,250,250)

      y_pos  = layer_height #@g_area_y2-1
      last_y = y_pos
      i =0
      while(i<=@division_count)
        last_y=  y_pos
        y_pos  =  y_pos - @division_height
        y_pos = 1 if (  y_pos <= 0 )
        image_filled_rectangle(@layers[0],1, y_pos,layer_width-1,last_y,250,250,250) if ( i % 2 == 0 )
        i = i+1
      end

      image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
      #image_destroy(@layers[0])

    end

    #Horizontal lines
    y_pos = @g_area_y2 - @division_height
    i=1
    while(i<=@division_count)
      self.draw_dotted_line(@g_area_x1,y_pos,@g_area_x2,y_pos,line_width,r,g,b) if ( y_pos > @g_area_y1 && y_pos < @g_area_y2 )
      y_pos = y_pos - @division_height
      i = i+1
    end
    # Vertical lines
    if (@g_area_x_offset == 0 )
      x_pos = @g_area_x1 + (@division_width) +@g_area_x_offset
      col_count = (@data_count.to_f-2).floor
    else

      x_pos = @g_area_x1 +@g_area_x_offset
      col_count = ( (@g_area_x2 - @g_area_x1) / @division_width )
    end
    i= 1

    while (i<=col_count)
      if ( x_pos > @g_area_x1 && x_pos < @g_area_x2 )
        self.draw_dotted_line((x_pos).floor,@g_area_y1,(x_pos).floor,@g_area_y2,line_width,r,g,b)
      end
      x_pos = x_pos + @division_width
      i= i+1
    end
  end
  # This function will draw an horizontal treshold ( this is an easy way to draw the 0 line ).
  # If show_label is set to true, the value of the treshold will be written over the graph.
  # If show_on_right is set to true, the value will be written on the right side of the graph.
  # r, g and b are used to set the line and text color.
  # Use tick_width to set the width of the ticks, if set to 0 this will draw a solid line.
  # You can optionnaly provide the caption of the treshold (by default the treshold value is used)

  def draw_treshold(value,r,g,b,show_label=false,show_on_right=false,tick_width=4,free_text=nil)
    b, g, r = validate_color(b, g, r)

    c_text_color =allocate_color(@picture,r,g,b)
    # c_text_color = GD2::Color.new(r,g,b)
    y = @g_area_y2 - (value - @vmin.to_f) * @division_ratio.to_f

    return(-1) if ( y <= @g_area_y1 || y >= @g_area_y2 )
    if ( tick_width == 0 )
      self.draw_line(@g_area_x1,y,@g_area_x2,y,r,g,b)
    else
      self.draw_dotted_line(@g_area_x1,y,@g_area_x2,y,tick_width,r,g,b)
    end
    if (show_label )
      if ( free_text.nil? )
        label = value
      else
        label = free_text
      end

      if ( show_on_right )
        image_ttf_text(@picture,@font_size,0,@g_area_x2+2,y+(@font_size/2),c_text_color,@font_name,label.to_s)
      else
        image_ttf_text(@picture,@font_size,0,@g_area_x1+2,y-(@font_size/2),c_text_color,@font_name,label.to_s)
      end
    end
  end
  #	This function will draw an area between two data series.
  # extracting the minimum and maximum value for each X positions.
  # You must specify the two series name and the area color.
  # You can specify the transparency which is set to 50% by default.

  def draw_area(data,serie1,serie2,r,g,b,alpha = 50)
    validate_data("draw_area",data)
    layer_width = @g_area_x2-@g_area_x1
    layer_height = @g_area_y2-@g_area_y1

    @layers[0] = image_create_true_color(layer_width,layer_height)
    image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
    image_color_transparent(@layers[0],255,255,255)

    x_pos    = @g_area_x_offset
    last_x_pos = -1
    last_y_pos1 = nil
    last_y_pos2= nil
    data.each do |key|
      value1 = key[serie1]
      value2 = key[serie2]
      y_pos1  = layer_height - ((value1-@vmin) * @division_ratio)
      y_pos2  = layer_height - ((value2-@vmin) * @division_ratio)

      if ( last_x_pos != -1 )
        points   = []
        points << last_x_pos
        points << last_y_pos1
        points << last_x_pos
        points <<  last_y_pos2
        points << x_pos
        points << y_pos2
        points << x_pos
        points << y_pos1
        image_filled_polygon(@layers[0],points,r,g,b,4)
      end
      last_y_pos1 = y_pos1
      last_y_pos2 = y_pos2
      last_x_pos  = x_pos
      x_pos= x_pos+ @division_width
    end
    image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
    image_destroy(@layers[0])
  end
# Use this function to add a border to your picture. Be carefull, drawing a border will change all the chart components positions, thus this call must be the last one before one of the rendering methods!!!
  # You can specify the size of the border and its color.
  # The width and height of the picture will be modified by 2x the size value.
  def add_border(size=3,r=0,g=0,b=0)
    width  = @x_size+2*size
    height = @y_size+2*size
    resampled    = image_create_true_color(width,height)
    image_filled_rectangle(resampled,0,0,width,height, r, g, b)
    image_copy(@picture,resampled,size,size,0,0,@x_size,@y_size)
    image_destroy(@picture)
    @x_size = width
    @y_size = height
    @picture = image_create_true_color(@x_size,@y_size)
    image_filled_rectangle(@picture,0,0,@x_size,@y_size,255,255,255)
    image_color_transparent(@picture,255,255,255)
    image_copy(resampled,@picture,0,0,0,0,@x_size,@y_size)
  end
# You can use this function to display the values contained in the series on top of the charts.
	# It is possible to specify one or multiple series to display using and array.
	def write_values(data,data_description,series)

		data_description = self.validate_data_description("write_values",data_description)
		 validate_data("write_values",data)
		series = [series]    if ( !series.is_a?(Array))
		id = 0
		color_id =0
		series.each do |col_name|
			data_description["description"].each do |key_i,value_i|
				if ( key_i == col_name )
					color_id = id
					id = id+1
				end
			end
			xpos  = @g_area_x1 + @g_area_x_offset
			xlast = -1
			data.each do |key|
				if ((!key[col_name].nil?) && (key[col_name].is_a?(Numeric)))
					value = key[col_name]
					ypos = @g_area_y2 - ((value-@vmin) * @division_ratio)
					positions = image_ftb_box(@font_size,0,@font_name,value.to_s)
					width  = positions[2] - positions[6]
					x_offset = xpos - (width/2)
					height = positions[3] - positions[7]
					y_offset = ypos - 4

					c_text_color = allocate_color(@picture,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"]);
					image_ttf_text(@picture,@font_size,0,x_offset,y_offset,c_text_color,@font_name,value.to_s)
				end
				xpos = xpos + @division_width
			end
		end
  end
  # Use this function to enable error reporting during the chart rendering.
	# By default messages are redirected to the console while using the render command and using GD while using the stroke command.
	# You can force the errors to be redirected to either cli or gd specifying it as parameter.
	def report_warnings(interface="cli")
		@error_reporting = true
		@error_interface = interface
	end
end
