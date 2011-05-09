module Scale
# Allow you to clear the scale : used if drawing multiple charts
  # You'll need to call this function only if you're planning to draw a second chart in the rendered picture.
  # Calling this function will clear the current scaling parameters thus you'll need to call again the draw_scale function before drawing any new chart.
  def clear_scale
    @vmin     = nil
    @vmax       = nil
    @v_x_min   = nil
    @v_x_max      = nil
    @divisions  = 0
    @x_divisions = 0
  end

  # Allow you to fix the scale, use this to bypass the automatic scaling
  # You can use this function to skip the automatic scaling.
  # vmin and vmax will be used to render the graph.
  def set_fixed_scale(v_min,v_max,divisions=5,v_x_min=0,v_x_max=0,x_divisions=5)
    @vmin      = v_min.to_f
    @vmax      = v_max.to_f
    @divisions = divisions.to_f

    if (!v_x_min == 0 )
      @v_x_min      = v_x_min.to_f
      @v_x_max      = v_x_max.to_f
      @x_divisions = x_divisions.to_f
    end
  end

  # Wrapper to the draw_scale function allowing a second scale to be drawn
  # It takes the same parameters of the draw_scale function.
  # The scale values will be written on the right side of the graph area.
  def draw_right_scale(data,data_description,scale_mode,r,g,b,draw_ticks=true,angle=0,decimals=1,with_margin=false,skip_labels=1)
    self.	draw_scale(data, data_description, scale_mode, r, g, b,draw_ticks,angle,decimals,with_margin,skip_labels,true)
  end

  # This function will draw both axis and write values on it. You can disable the labelling of the axis setting draw_ticks to false. angle can be used to rotate the vertical ticks labels.
  # decimal specify the number of decimal values we want to keep. Setting draw_ticks to false will not draw vertical & horizontal ticks on the axis ( labels will also not be written ).
  # There is four way of computing scales :
  # * Getting Max & Min values per serie : scale_mode = Rchart::SCALE_NORMAL
  # * Like the previous one but setting the min value to 0 : scale_mode = Rchart::SCALE_START0
  # * Getting the series cumulative Max & Min values : scale_mode = Rchart::SCALE_ADDALL
  # * Like the previous one but setting the min value to 0 : scale_mode = Rchart::SCALE_ADDALLSTART0
  # This will depends on the kind of graph you are drawing,   Drawing graphs were you want to fix the min value to 0 you must use the Rchart::SCALE_START0 option.
  # You can display only one x label every xi labels using the skip_labels parameter.
  # Keeping with_margin to false will make the chart use all the width of the graph area. For most graphs the rendering will be better. In some circumstances you'll have to set it to true ( introducing left & right margin ) : bar charts will require it.
  def draw_scale(data,data_description,scale_mode,r,g,b,draw_ticks=true,angle=0,decimals=1,with_margin=false,skip_labels=1,right_scale=false)
    # Validate the Data and DataDescription array
    data = self.validate_data("draw_scale",data)
    c_text_color         = allocate_color(@picture,r,g,b)
    self.draw_line(@g_area_x1,@g_area_y1,@g_area_x1,@g_area_y2,r,g,b)
    self.draw_line(@g_area_x1,@g_area_y2,@g_area_x2,@g_area_y2,r,g,b)
    scale =0
    divisions =0
    if(@vmin.nil? && @vmax.nil?)
      if (!data_description["values"][0].nil?)
        #My hack TODO for LINE GRAPH
        if data_description["values"].is_a?(Array)
          @vmin =data[0][data_description["values"][0]]
          @vmax =data[0][data_description["values"][0]]
        else
          @vmin =data[0][data_description["values"][0]]
          @vmax =data[0][data_description["values"]]
        end

      else
        @vmin = 2147483647
        @vmax = -2147483647
      end
#       /* Compute Min and Max values */
      if(scale_mode == Rchart::SCALE_NORMAL || scale_mode == Rchart::SCALE_START0)
        @vmin = 0 if (scale_mode == Rchart::SCALE_START0 )

        data.each do |key|
          data_description["values"].each do |col_name|
            if(!key[col_name].nil?)
              value = key[col_name]
              if (value.is_a?(Numeric))
                @vmax = value if ( @vmax < value)
                @vmin = value  if ( @vmin > value)
              end
            end
          end
        end
      elsif ( scale_mode == Rchart::SCALE_ADDALL || scale_mode == Rchart::SCALE_ADDALLSTART0 ) # Experimental
        @vmin = 0 if (scale_mode == Rchart::SCALE_ADDALLSTART0)
        data.each do |key|
          sum = 0
          data_description["values"].each do|col_name|
            if (!key[col_name].nil?)
              value =key[col_name]
              sum  += value if ((value).is_a?(Numeric))
            end
          end
          @vmax = sum if (@vmax < sum)
          @vmin = sum if (@vmin > sum)
        end

      end

      if(@vmax.is_a?(String))
        @vmax = @vmax.gsub(/\.[0-9]+/,'')+1 if (@vmax > @vmax.gsub(/\.[0-9]+/,'') )
      end
      # If all values are the same */
      if ( @vmax == @vmin )
        if ( @vmax >= 0 )
          @vmax = @vmax+1
        else
          @vmin = @vmin-1
        end
      end

      data_range = @vmax - @vmin
      data_range = 0.1 if (data_range.to_f == 0.0)

      #Compute automatic scaling */
      scale_ok = false
      factor = 1
      min_div_height = 25
      max_divs = (@g_area_y2 - @g_area_y1)*1.0 / min_div_height

      if (@vmin == 0 && @vmax == 0 )
        @vmin = 0
        @vmax = 2
        scale = 1
        divisions = 2
      elsif (max_divs > 1)
        while(!scale_ok)
          scale1 = ( @vmax - @vmin )*1.0 / factor
          scale2 = ( @vmax - @vmin )*1.0 /factor / 2
      #    scale4 = ( @vmax - @vmin )*1.0 / factor / 4
          if ( scale1 > 1 && scale1 <= max_divs && !scale_ok)
            scale_ok = true
            divisions = (scale1).floor
            scale = 1
          end
          if (scale2 > 1 && scale2 <= max_divs && !scale_ok)
            scale_ok = true
            divisions = (scale2).floor
            scale = 2
          end
          if (!scale_ok)
            factor = factor * 10 if ( scale2 > 1 )
            factor = factor / 10  if ( scale2 < 1 )
          end
        end # while end
        if ((((@vmax*1.0 / scale) / factor)).floor != ((@vmax*1.0 / scale) / factor))
          grid_id     = ( @vmax*1.0 / scale / factor).floor  + 1
          @vmax       = grid_id * scale * factor
          divisions   = divisions+1
        end

        if (((@vmin*1.0 / scale) / factor).floor != ((@vmin*1.0 / scale) / factor))

          grid_id     = ( @vmin*1.0 / scale / factor).floor
          @vmin       = grid_id * scale * factor*1.0
          divisions   = divisions+1
        end

      else #/* Can occurs for small graphs */
        scale = 1
      end
      divisions = 2 if ( divisions.nil? )

      divisions = divisions-1 if (scale == 1 && divisions%2 == 1)

    else
      divisions = @divisions
    end

    @division_count = divisions
    data_range = @vmax - @vmin
    data_range = 0.1  if (data_range.to_f == 0.0 )
    @division_height = ( @g_area_y2 - @g_area_y1 )*1.0 / divisions
    @division_ratio  = ( @g_area_y2 - @g_area_y1 )*1.0 /data_range
    @g_area_x_offset  = 0
    if ( data.count > 1 )
      if ( with_margin == false)
        @division_width = ( @g_area_x2 - @g_area_x1 )*1.0 / ((data).count-1)
      else
        @division_width = ( @g_area_x2 - @g_area_x1 ) *1.0/ (data).count
        @g_area_x_offset  = @division_width*1.0 / 2
      end
    else
      @division_width = (@g_area_x2 - @g_area_x1)*1.0
      @g_area_x_offset  = @division_width*1.0 / 2
    end

    @data_count = (data).count
    return(0) if (draw_ticks == false )
    ypos = @g_area_y2
    xmin = nil
    i =1

    while(i<= divisions+1)
      if (right_scale )
        self.draw_line(@g_area_x2,ypos,@g_area_x2+5,ypos,r,g,b)
      else
        self.draw_line(@g_area_x1,ypos,@g_area_x1-5,ypos,r,g,b)
      end
      value     = @vmin*1.0 + (i-1) * (( @vmax - @vmin ) / divisions)
      value     = (round_of(value * (10**decimals),2)) / (10**decimals)
      value= value.round if value.floor == value.ceil
      value = "#{value} #{data_description['unit']['y']}"  if ( data_description["format"]["y"]== "number")
      value = self.to_time(value)                  if ( data_description["format"]["y"] == "time" )
      value = self.to_date(value)                  if ( data_description["format"]["y"] == "date" )
      value = self.to_metric(value)                if ( data_description["format"]["Y"] == "metric" )
      value = self.to_currency(value)             if ( data_description["format"]["Y"] == "currency" )
      position  = image_ftb_box(@font_size,0,@font_name,value)
      text_width =position[2]-position[0]
      if ( right_scale )
        image_ttf_text(@picture,@font_size,0,@g_area_x2+10,ypos+(@font_size/2),c_text_color,@font_name,value)
        xmin = @g_area_x2+15+text_width if (xmin.nil? || xmin < @g_area_x2+15+text_width  )
      else
        image_ttf_text(@picture,@font_size,0,@g_area_x1-10-text_width,ypos+(@font_size/2),c_text_color,@font_name,value)
        xmin = @g_area_x1-10-text_width if (  xmin.nil? || xmin > @g_area_x1-10-text_width)
      end
      ypos = ypos - @division_height
      i = i+1
    end
    # Write the Y Axis caption if set */

    if (!data_description["axis"].nil? && !data_description["axis"]["y"].nil? )
      position   = image_ftb_box(@font_size,90,@font_name,data_description["axis"]["y"])
      text_height = (position[1]).abs+(position[3]).abs
      text_top    = ((@g_area_y2 - @g_area_y1) / 2) + @g_area_y1 + (text_height/2)

      if (right_scale )
        image_ttf_text(@picture,@font_size,90,xmin+@font_size,text_top,c_text_color,@font_name,data_description["axis"]["y"])
      else
        image_ttf_text(@picture,@font_size,90,xmin-@font_size,text_top,c_text_color,@font_name,data_description["axis"]["y"])
      end
    end
    # Horizontal Axis */
    xpos = @g_area_x1 + @g_area_x_offset
    id = 1
    ymax = nil
    data.each do |key|
      if ( id % skip_labels == 0 )
        self.draw_line((xpos).floor,@g_area_y2,(xpos).floor,@g_area_y2+5,r,g,b)
        value      =key[data_description["position"]]
        value =  "#{value} #{data_description['unit']['x']}" if ( data_description["format"]["x"] == "number" )
        value = self.to_time(value)       if ( data_description["format"]["x"] == "time" )
        value = self.to_date(value)       if ( data_description["format"]["x"] == "date" )
        value = self.to_metric(value)     if ( data_description["format"]["x"] == "metric" )
        value = self.to_currency(value)   if ( data_description["format"]["x"] == "currency" )
        position   = image_ftb_box(@font_size,angle,@font_name,value.to_s)
        text_width  = (position[2]).abs+(position[0]).abs
        text_height = (position[1]).abs+(position[3]).abs
        if ( angle == 0 )
          ypos = @g_area_y2+18
          image_ttf_text(@picture,@font_size,angle,(xpos).floor-(text_width/2).floor,ypos,c_text_color,@font_name,value.to_s)
        else
          ypos = @g_area_y2+10+text_height
          if ( angle <= 90 )
            image_ttf_text(@picture,@font_size,angle,(xpos).floor-text_width+5,ypos,c_text_color,@font_name,value.to_s)
          else
            image_ttf_text(@picture,@font_size,angle,(xpos).floor+text_width+5,ypos,c_text_color,@font_name,value.to_s)
          end
        end
        ymax = ypos if (ymax.nil? ||(!ymax.nil? && ymax < ypos))
      end
      xpos = xpos + @division_width
      id = id+1
    end   #loop ended
    #Write the X Axis caption if set */

    if ((!data_description["axis"].nil? && !data_description["axis"]["x"].nil?) )
      position   = image_ftb_box(@font_size,90,@font_name,data_description["axis"]["x"])
      text_width  = (position[2]).abs+(position[0]).abs
      text_left   = ((@g_area_x2 - @g_area_x1) / 2) + @g_area_x1 + (text_width/2)
      image_ttf_text(@picture,@font_size,0,text_left,ymax+@font_size+5,c_text_color,@font_name,data_description["axis"]["x"].to_s)
    end

  end

  # This function is used by scatter charts.
  # It will compute everything needed to draw the associated line and plot charts.
  # You must specify the name of the two series that will be used as X and Y data. By default this function will compute the min & max values of both series, anyway you can override the automatic scaling by calling first the setFixedScale function.
  def draw_xy_scale(data,data_description,y_serie_name,x_serie_name,r,g,b,with_margin=0,angle=0,decimals=1)

    self.validate_data("draw_xy_scale",data)
    c_text_color         = allocate_color(@picture,r,g,b)
    self.draw_line(@g_area_x1,@g_area_y1,@g_area_x1,@g_area_y2,r,g,b)
    self.draw_line(@g_area_x1,@g_area_y2,@g_area_x2,@g_area_y2,r,g,b)

    # Process Y scale */
    if(@vmin.nil? && @vmax.nil?)
      @vmin = data[0][y_serie_name]
      @vmax = data[0][y_serie_name]
      data.each do |key|
        if !key[y_serie_name].nil?
          value = key[y_serie_name]
          if (value.is_a?(Numeric))
            @vmax = value if ( @vmax < value)
            @vmin = value  if ( @vmin > value)
          end
        end
      end

      if(@vmax.is_a?(String))
        @vmax = @vmax.gsub(/\.[0-9]+/,'')+1 if (@vmax > @vmax.gsub(/\.[0-9]+/,'') )
      end
      data_range = @vmax - @vmin
      data_range = 0.1 if (data_range.to_f == 0.0 )

      #Compute automatic scaling
      scale_ok = false
      factor = 1
      min_div_height = 25
      max_divs = (@g_area_y2 - @g_area_y1)*1.0 / min_div_height
      if (@vmin == 0 && @vmax == 0 )
        @vmin = 0
        @vmax = 2
        scale = 1
        divisions = 2
      elsif (max_divs > 1)
        while(!scale_ok)
          scale1 = ( @vmax - @vmin )*1.0 / factor
          scale2 = ( @vmax - @vmin )*1.0 /factor / 2
          scale4 = ( @vmax - @vmin )*1.0 / factor / 4

          if ( scale1 > 1 && scale1 <= max_divs && !scale_ok)
            scale_ok = true
            divisions = (scale1).floor
            scale = 1
          end
          if ( scale2 > 1 && scale2 <= max_divs && !scale_ok)
            scale_ok = true
            divisions = (scale2).floor
            scale = 2
          end
          if (!scale_ok)
            factor = factor * 10  if ( scale2 > 1 )
            factor = factor / 10  if ( scale2 < 1 )
          end
        end
        if ((((@vmax*1.0 / scale) / factor)).floor != ((@vmax*1.0 / scale) / factor))
          grid_id     = ( @vmax*1.0 / scale / factor).floor  + 1
          @vmax       = grid_id * scale * factor
          divisions   = divisions+1
        end

        if (((@vmin*1.0 / scale) / factor).floor != ((@vmin*1.0 / scale) / factor))

          grid_id     = ( @vmin*1.0 / scale / factor).floor
          @vmin       = grid_id * scale * factor*1.0
          divisions   = divisions+1
        end

      else #/* Can occurs for small graphs */
        scale = 1
      end
      divisions = 2 if ( divisions.nil? )

      if ( is_real_int((@vmax-@vmin)/(divisions-1)))
        divisions-=1
      elsif ( is_real_int((@vmax-@vmin)/(divisions+1)))
        divisions+=1
      end
    else
      divisions =@divisions
    end
    @division_count = divisions

    data_range = @vmax - @vmin
    data_range = 0.1  if (data_range.to_f == 0.0 )
    @division_height = ( @g_area_y2 - @g_area_y1 )*1.0 / divisions
    @division_ratio  = ( @g_area_y2 - @g_area_y1 )*1.0 /data_range
    ypos = @g_area_y2
    xmin = nil
    i =1

    while(i<= divisions+1)
      self.draw_line(@g_area_x1,ypos,@g_area_x1-5,ypos,r,g,b)
      value     = @vmin*1.0 + (i-1) * (( @vmax - @vmin ) / divisions)
      value     = (round_of(value * (10**decimals),2)) / (10**decimals)
      value= value.round if value.floor == value.ceil
      value = "#{value} #{data_description['unit']['y']}"  if ( data_description["format"]["y"]== "number")
      value = self.to_time(value)                  if ( data_description["format"]["y"] == "time" )
      value = self.to_date(value)                  if ( data_description["format"]["y"] == "date" )
      value = self.to_metric(value)                if ( data_description["format"]["Y"] == "metric" )
      value = self.to_currency(value)             if ( data_description["format"]["Y"] == "currency" )

      position  = image_ftb_box(@font_size,0,@font_name,value)
      text_width =position[2]-position[0]
      image_ttf_text(@picture,@font_size,0,@g_area_x1-10-text_width,ypos+(@font_size/2),c_text_color,@font_name,value)
      xmin = @g_area_x1-10-text_width if (  xmin.nil? || xmin > @g_area_x1-10-text_width)
      ypos = ypos - @division_height
      i = i+1

    end

    # Process X scale */
    if(@v_x_min.nil? && @v_x_max.nil?)

      @v_x_min =data[0][x_serie_name]
      @v_x_max =data[0][x_serie_name]
      data.each do |key|

        if !key[x_serie_name].nil?
          value = key[x_serie_name]
          if (value.is_a?(Numeric))

            @v_x_max = value if ( @v_x_max < value)
            @v_x_min = value  if ( @v_x_min > value)
          end
        end
      end

      if (@v_x_max.is_a?(String))
        @v_x_max = @v_x_max.gsub(/\.[0-9]+/,'')+1 if (@v_x_max > @v_x_max.gsub(/\.[0-9]+/,'') )
      end

      data_range = @vmax - @vmin
      data_range = 0.1 if (data_range.to_f == 0.0 )

      # Compute automatic scaling
      scale_ok = false
      factor = 1
      min_div_width = 25
      max_divs = (@g_area_x2 - @g_area_x1) / min_div_width

      if ( @v_x_min == 0 && @v_x_max == 0 )
        @v_x_min = 0
        @v_x_max = 2
        scale = 1
        x_divisions = 2
      elsif (max_divs > 1)

        while(!scale_ok)
          scale1 = ( @v_x_max - @v_x_min ) / factor
          scale2 = ( @v_x_max - @v_x_min ) / factor / 2
          scale4 = ( @v_x_max - @v_x_min ) / factor / 4
          if ( scale1 > 1 && scale1 <= max_divs && !scale_ok)
            scale_ok = true
            x_divisions = (scale1).floor
            scale = 1
          end

          if ( scale2 > 1 && scale2 <= max_divs && !scale_ok)
            scale_ok = true
            x_divisions = (scale2).floor

            scale = 2
          end
          if (!scale_ok)
            factor = factor * 10 if ( scale2 > 1 )
            factor = factor / 10  if ( scale2 < 1 )
          end
        end

        if ( (@v_x_max*1.0 / scale / factor).floor != @v_x_max / scale / factor)
          grid_id     =  ( @v_x_max*1.0 / scale / factor).floor + 1
          @v_x_max = grid_id * scale * factor
          x_divisions+=1
        end

        if ( (@v_x_min*1.0 / scale / factor).floor != @v_x_min / scale / factor)
          grid_id     = ( @v_x_min / scale / factor).floor
          @v_x_min = grid_id * scale * factor
          x_divisions+=1
        end
      else #/* Can occurs for small graphs */
        scale = 1
      end
      x_divisions = 2 if ( x_divisions.nil? )

      if ( is_real_int((@v_x_max-@v_x_min)/(x_divisions-1)))
        x_divisions-=1
      elsif ( is_real_int((@v_x_max-@v_x_min)/(x_divisions+1)))
        x_divisions+=1
      end
    else

      x_divisions = @x_divisions
    end

    @x_division_count = divisions
    @data_count      = divisions + 2

    x_data_range = @v_x_max - @v_x_min
    x_data_range = 0.1   if ( x_data_range == 0 )

    @division_width   = ( @g_area_x2 - @g_area_x1 ) / x_divisions
    @x_division_ratio  = ( @g_area_x2 - @g_area_x1 ) / x_data_range
    xpos = @g_area_x1
    ymax =nil
    i=1

    while(i<= x_divisions+1)
      self.draw_line(xpos,@g_area_y2,xpos,@g_area_y2+5,r,g,b)
      value     = @v_x_min + (i-1) * (( @v_x_max - @v_x_min ) / x_divisions)
      value     = (round_of(value * (10**decimals),2)) / (10**decimals)
      value= value.round if value.floor == value.ceil
      value = "#{value}#{data_description['unit']['y']}"  if ( data_description["format"]["y"]== "number")
      value = self.to_time(value)                  if ( data_description["format"]["y"] == "time" )
      value = self.to_date(value)                  if ( data_description["format"]["y"] == "date" )
      value = self.to_metric(value)                if ( data_description["format"]["Y"] == "metric" )
      value = self.to_currency(value)             if ( data_description["format"]["Y"] == "currency" )
      position  = image_ftb_box(@font_size,angle,@font_name,value)
      text_width =position[2].abs+position[0].abs
      text_height = position[1].abs+position[3].abs

      if ( angle == 0 )
        ypos = @g_area_y2+18
        image_ttf_text(@picture,@font_size,angle,(xpos).floor-(text_width/2).floor,ypos,c_text_color,@font_name,value)
      else

        ypos = @g_area_y2+10+text_height
        if ( angle <= 90 )
          image_ttf_text(@picture,@font_size,angle,(xpos).floor-text_width+5,ypos,c_text_color,@font_name,value)
        else
          image_ttf_text(@picture,@font_size,angle,(xpos).floor+text_width+5,ypos,c_text_color,@font_name,value)
        end

      end

      ymax = ypos if (ymax.nil? || ymax < ypos)
      i=i+1
      xpos = xpos + @division_width
    end
    #Write the Y Axis caption if set
    if ((!data_description["axis"].nil? && !data_description["axis"]["y"].nil?) )
      position   = image_ftb_box(@font_size,90,@font_name,data_description["axis"]["y"])
      text_height  = (position[1]).abs+(position[3]).abs
      text_top   = ((@g_area_y2 - @g_area_y1) / 2) + @g_area_y1 + (text_width/2)
      image_ttf_text(@picture,@font_size,90,xmin-@font_size,text_top,c_text_color,@font_name,data_description["axis"]["y"].to_s)
    end
    if ((!data_description["axis"].nil? && !data_description["axis"]["x"].nil?) )
      position   = image_ftb_box(@font_size,90,@font_name,data_description["axis"]["x"])
      text_width  = (position[2]).abs+(position[0]).abs
      text_left   = ((@g_area_x2 - @g_area_x1) / 2) + @g_area_x1 + (text_width/2)
      image_ttf_text(@picture,@font_size,0,text_left,ymax+@font_size+5,c_text_color,@font_name,data_description["axis"]["x"].to_s)
    end

  end

end
