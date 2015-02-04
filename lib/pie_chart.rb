module PieChart
  # This function will draw a classical non-exploded pie chart.
  # * To do so you must specify the data & data_description array.Only one serie of data is allowed for pie graph.
  # * You can associate a description of each value in another serie by marking it using the set_abscise_label_serie function.
  # * You must specify the center position of the chart. You can also optionally specify the radius of the pie and if the percentage should be printed.
  # * r,g,b can be used to set the color of the line that will surround each pie slices.
  # * You can specify the number of decimals you want to be displayed in the labels (default is 0 )
  # By default no labels are written around the pie chart. You can use the following modes for the draw_labels parameter
  # * Rchart:: PIE_NOLABEL No labels displayed
  # * Rchart:: PIE_PERCENTAGE Percentages are displayed
  # * Rchart:: PIE_LABELS Series labels displayed
  # * Rchart:: PIE_PERCENTAGE_LABEL Series labels & percentage displayed
  # This will draw a pie graph centered at (150-150) with a radius of 100, no labels
  # * chart.draw_basic_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150)
  # This will draw a pie graph centered at (150-150) with a radius of 50 and percentages
  # * chart.draw_basic_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,50,Rchart::PIE_PERCENTAGE)
  # This will draw a pie graph centered at (150-150) with a radius of 100, captions and black borders
  # * chart.draw_basic_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,100,Rchart::PIE_PERCENTAGE,0,0,0)
  def draw_basic_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=Rchart::PIE_NOLABEL,r=255,g=255,b=255,decimals=0)
    data_description = validate_data_description("draw_basic_pie_graph",data_description,false)
    validate_data("drawBasicPieGraph",data)
    # Determine pie sum
    series = 0
    pie_sum = 0
    i_values = []
    r_values  = []
    i_labels  = []
    data_description["values"].each do|col_name|
      if (col_name != data_description["position"])
        series = series+1
        data.each do |key|
          if (!key[col_name].nil?)
            pie_sum = pie_sum + key[col_name]
            i_values << key[col_name]
            i_labels   << key[data_description["position"]]
          end
        end
      end
    end


    # Validate serie
    if ( series != 1 )
      raise_fatal("Pie chart can only accept one serie of data.")
    end
    splice_ratio         = 360.0 / pie_sum
    splice_percent       = 100.0 / pie_sum

    #Calculate all polygons
    angle    = 0
    top_plots = []
    i_values.each_with_index do |value,key|

      top_plots[key]= [x_pos]
      top_plots[key]<< y_pos
      # Process labels position & size
      caption = ""
      if ( !(draw_labels == Rchart::PIE_NOLABEL) )
        t_angle  = angle+(value*splice_ratio/2)
        if (draw_labels == Rchart::PIE_PERCENTAGE)
          caption  = ((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        elsif (draw_labels == Rchart::PIE_LABELS)
          caption  = i_labels[key]
        elsif (draw_labels == Rchart::PIE_PERCENTAGE_LABEL)
          caption  = i_labels[key].to_s+"\r\n"+"."+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        elsif (draw_labels == Rchart::PIE_PERCENTAGE_LABEL)
          caption  = i_labels[key].to_s+"\r\n"+"."+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        end
        position   = image_ftb_box(@font_size,0,@font_name,caption)
        text_width  = position[2]-position[0]
        text_height = (position[1].abs)+(position[3].abs)

        tx = Math.cos((t_angle) * Math::PI / 180 ) * (radius+10) + x_pos

        if ( t_angle > 0 && t_angle < 180 )
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (radius+10) + y_pos + 4
        else
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (radius+4) + y_pos - (text_height/2)
        end
        tx = tx - text_width if ( t_angle > 90 && t_angle < 270 )

        c_text_color = allocate_color(@picture,70,70,70)
        image_ttf_text(@picture,@font_size,0,tx,ty,c_text_color,@font_name,caption)
      end
      # Process pie slices
      i_angle = angle
      while(i_angle <=angle+value*splice_ratio)

        top_x = (Math.cos(i_angle * Math::PI / 180 )) * radius + x_pos
        top_y = (Math.sin(i_angle * Math::PI/ 180 ))  * radius + y_pos
        top_plots[key] << (top_x)
        top_plots[key] <<(top_y)
        i_angle = i_angle+0.5
      end
      top_plots[key]<< x_pos
      top_plots[key] << y_pos
      angle = i_angle
    end
    poly_plots = top_plots
    # Draw Top polygons
    poly_plots.each_with_index do |value,key|
      image_filled_polygon(@picture, poly_plots[key], @palette[key]["r"],@palette[key]["g"],@palette[key]["b"])
    end
    	draw_circle(x_pos-0.5,y_pos-0.5,radius,r,g,b)
    	draw_circle(x_pos-0.5,y_pos-0.5,radius+0.5,r,g,b)
    # Draw Top polygons
    top_plots.each_with_index do  |value,key|
      j = 0
      while(j<=top_plots[key].count-4 )
        draw_line(top_plots[key][j],top_plots[key][j+1],top_plots[key][j+2],top_plots[key][j+3],r,g,b)
        j =j+2
      end
    end
  end

  # This function will draw a 3D pie graph.
  # * To do so you must specify the data & data_description array.
  # * Only one serie of data is allowed for pie graph.
  # * You can associate a description of each value in another serie by marking it using the set_abscise_label_serie function. You must specify the center position of the chart.
  # * You can also optionally specify the radius of the pie, if the percentage should be printed, the 3D skew factor and the height of all splices.
  # * If enhance_colors is set to true, pie edges will be enhanced.
  # * If splice_distance is greated than 0, the pie will be exploded.
  # * You can specify the number of decimals you want to be displayed in the labels (default is 0 ).
  # By default no labels are written around the pie chart. You can use the following modes for the draw_labels parameter:
  # * Rchart:: PIE_NOLABEL No labels displayed
  # * Rchart:: PIE_PERCENTAGE Percentages are displayed
  # * Rchart:: PIE_LABELS Series labels displayed
  # * Rchart:: PIE_PERCENTAGE_LABEL Series labels & percentage displayed
  #	This will draw a pie graph centered at (150-150) with a radius of 100, no labels
  # * chart.draw_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150)
  # This will draw a pie graph centered at (150-150) with a radius of 50 and percentages
  # * chart.draw_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,50,Rchart::PIE_PERCENTAGE)
  # This will draw a pie graph centered at (150-150) with a radius of 100, captions and a skew factor of 30
  # * chart.draw_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,100,Rchart::PIE_PERCENTAGE,true,30)
  # This will draw a pie graph (..) exploded
  # * chart.draw_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,100,Rchart::PIE_PERCENTAGE,true,30,10,10)
  def draw_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=Rchart::PIE_NOLABEL,enhance_colors=true,skew=60,splice_height=20,splice_distance=0,decimals=0)
    data_description = validate_data_description("draw_pie_graph",data_description,false)
    validate_data("draw_pie_graph",data)

    #Determine pie sum
    series = 0
    pie_sum= 0
    rpie_sum = 0
    i_values = []
    r_values  = []
    i_labels  = []
    series = 0

    data_description["values"].each do|col_name|
      if (col_name != data_description["position"])
        series = series+1
        data.each do |key|
          if (!key[col_name].nil?)
            if (key[col_name] == 0)
              i_values  << 0
              r_values  << 0
              i_labels  << 0
              i_labels<< key[data_description["position"]]
            else
              pie_sum+=  key[col_name]
              i_values << key[col_name]
              i_labels << key[data_description["position"]]
              r_values << key[col_name]
              rpie_sum += key[col_name]
            end
          end
        end
      end
    end

    # Validate serie

    #RaiseFatal("Pie chart can only accept one serie of data.")
    #puts "Error Pie chart can only accept one serie of data." if ( series != 1 )
    splice_distance_ratio = splice_distance
    skew_height          = (radius * skew) / 100
    splice_ratio         = ((360 - splice_distance_ratio *i_values.count*1.0)  / pie_sum)
    splice_percent       = 100.0 / pie_sum
    r_splice_percent      = 100.0 / rpie_sum
    #Calculate all polygons
    angle    = 0
    c_dev = 5
    top_plots = []
    bot_plots = []
    atop_plots = []
    abot_plots = []
    i_values.each_with_index do |value,key|
      x_cent_pos = Math.cos((angle-c_dev+(value*splice_ratio+splice_distance_ratio)/2) * 3.1418 / 180 ) * splice_distance + x_pos
      y_cent_pos = Math.sin((angle-c_dev+(value*splice_ratio+splice_distance_ratio)/2) * 3.1418 / 180 ) * splice_distance + y_pos
      x_cent_pos2 = Math.cos((angle+c_dev+(value*splice_ratio+splice_distance_ratio)/2) * 3.1418 / 180 ) * splice_distance + x_pos
      y_cent_pos2 = Math.sin((angle+c_dev+(value*splice_ratio+splice_distance_ratio)/2) * 3.1418 / 180 ) * splice_distance + y_pos
      top_plots[key] = [(x_cent_pos).round]
      bot_plots[key] = [(x_cent_pos).round]
      top_plots[key] << (y_cent_pos).round
      bot_plots[key] << (y_cent_pos + splice_height).round
      atop_plots[key] = [x_cent_pos]
      abot_plots[key] = [x_cent_pos]
      atop_plots[key] << y_cent_pos
      abot_plots[key]   << y_cent_pos + splice_height
      # Process labels position & size
      caption = ""
      if ( !(draw_labels == Rchart::PIE_NOLABEL) )

        t_angle   = angle+(value*splice_ratio/2)
        if (draw_labels == Rchart::PIE_PERCENTAGE)
          caption  = ((r_values[key] * (10**decimals) * r_splice_percent)/(10**decimals)).round.to_s+"%"
        elsif (draw_labels == Rchart::PIE_LABELS)
          caption  = i_labels[key]
        elsif (draw_labels == Rchart::PIE_PERCENTAGE_LABEL)
          caption  = i_labels[key].to_s+"\r\n"+(((value * 10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        end
        position   = image_ftb_box(@font_size,0,@font_name,caption)
        text_width  =position[2]-position[0]
        text_height = ( position[1]).abs+(position[3]).abs

        tx = Math.cos((t_angle) * Math::PI / 180 ) * (radius + 10)+ x_pos

        if ( t_angle > 0 && t_angle < 180 )
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (skew_height + 10) + y_pos + splice_height + 4
        else
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (skew_height + 4) + y_pos - (text_height/2)
        end
        if ( t_angle > 90 && t_angle < 270 )
          tx = tx - text_width
        end
        #c_text_color = $this->AllocateColor(@picture,70,70,70)
        c_text_color = allocate_color(@picture,70,70,70)
        image_ttf_text(@picture,@font_size,0,tx,ty,c_text_color,@font_name,caption)
      end

      # Process pie slices

      i_angle = angle
      i_angle = i_angle.to_f

      while(i_angle <=angle+value*splice_ratio)

        top_x = (Math.cos(i_angle * Math::PI / 180 )) * radius + x_pos
        top_y = (Math.sin(i_angle * Math::PI/ 180 )) * skew_height + y_pos

        top_plots[key] << (top_x).round
        bot_plots[key] <<(top_x).round
        top_plots[key] <<(top_y).round
        bot_plots[key] << (top_y + splice_height).round
        atop_plots[key] << top_x
        abot_plots[key] << top_x
        atop_plots[key] << top_y
        abot_plots[key] << top_y + splice_height
        i_angle=i_angle+0.5
      end
      top_plots[key] << (x_cent_pos2).round
      bot_plots[key] << (x_cent_pos2).round
      top_plots[key] << (y_cent_pos2).round
      bot_plots[key] << (y_cent_pos2 + splice_height).round
      atop_plots[key] << x_cent_pos2
      abot_plots[key] << x_cent_pos2
      atop_plots[key] << y_cent_pos2
      abot_plots[key] << y_cent_pos2 + splice_height
      angle = i_angle + splice_distance_ratio
    end

    # Draw Bottom polygons
    i_values.each_with_index do |val,key|
      c_graph_lo = allocate_color(@picture,@palette[key]["r"]-20,@palette[key]["g"]-20,@palette[key]["b"]-20)
      image_filled_polygon(@picture,bot_plots[key],@palette[key]["r"]-20,@palette[key]["g"]-20,@palette[key]["b"]-20)
      if (enhance_colors)
        en = -10
      else
        en = 0
      end
      j =0
      while(j<=(abot_plots[key].length)-4)
        draw_line(abot_plots[key][j],abot_plots[key][j+1],abot_plots[key][j+2],abot_plots[key][j+3],@palette[key]["r"]+en,@palette[key]["g"]+en,@palette[key]["b"]+en)
        j= j+2
      end
    end

    # Draw pie layers
    if ( enhance_colors )
      color_ratio = 30 / splice_height
    else
      color_ratio = 25 / splice_height
    end
    i = splice_height-1
    while(i>=1)
      i_values.each_with_index do |val,key|
        c_graph_lo = allocate_color(@picture,@palette[key]["r"]-10,@palette[key]["g"]-10,@palette[key]["b"]-10)
        plots =[]
        plot = 0
        top_plots[key].each_with_index do |value2,key2|
          plot = plot+1
          if ( plot % 2 == 1 )
            plots <<  value2
          else
            plots << value2+i
          end
        end
        image_filled_polygon(@picture,plots,@palette[key]["r"]-10,@palette[key]["g"]-10,@palette[key]["b"]-10)
        index       = (plots).count
        if (enhance_colors )
          color_factor = -20 + (splice_height - $i) * color_ratio
        else
          color_factor = 0
        end

        draw_antialias_pixel(plots[0],plots[1],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor)
        draw_antialias_pixel(plots[2],plots[3],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor)
        draw_antialias_pixel(plots[index-4],plots[index-3],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor)
      end
      i = i-1
    end
    #Draw Top polygons
    key = i_values.length-1
    while(key>=0)
      c_graph_lo = allocate_color(@picture,@palette[key]["r"],@palette[key]["g"],@palette[key]["b"])
      image_filled_polygon(@picture,top_plots[key],@palette[key]["r"],@palette[key]["g"],@palette[key]["b"])

      if ( enhance_colors )
        en = 10
      else
        en = 0
      end
      j = 0

      while(j<=(atop_plots[key]).length-4)
        draw_line(atop_plots[key][j],atop_plots[key][j+1],atop_plots[key][j+2],atop_plots[key][j+3],@palette[key]["r"]+en,@palette[key]["g"]+en,@palette[key]["b"]+en)
        j = j+2
      end
      key = key -1
    end
  end
  # This function is an alias of the draw_flat_pie_graph function.
  def draw_flat_pie_graph_with_shadow(data,data_description,x_pos,y_pos,radius=100,draw_labels=Rchart::PIE_NOLABEL,splice_distance=0,decimals=0)
    draw_flat_pie_graph(data,data_description,x_pos+@shadow_x_distance,y_pos+@shadow_y_distance,radius,Rchart::PIE_NOLABEL,splice_distance,decimals,true)
    draw_flat_pie_graph(data,data_description,x_pos,y_pos,radius,draw_labels,splice_distance,decimals,false)
  end

  # This function will draw a flat 2D pie graph.
  # To do so you must specify the data & data_description array.
  # * Only one serie of data is allowed for pie graph.
  # * You can associate a description of each value in another serie by marking it using the set_abscise_label_serie function. You must specify the center position of the chart.
  # * You can also optionally specify the radius of the pie and if the percentage should be printed.
  # * If splice_distance is greated than 0, the pie will be exploded.
  # * You can specify the number of decimals you want to be displayed in the labels (default is 0 )
  # By default no labels are written around the pie chart. You can use the following modes for the draw_labels parameter:
  # * Rchart:: PIE_NOLABEL No labels displayed
  # * Rchart:: PIE_PERCENTAGE Percentages are displayed
  # * Rchart:: PIE_LABELS Series labels displayed
  # * Rchart:: PIE_PERCENTAGE_LABEL Series labels & percentage displayed
  # This will draw a pie graph centered at (150-150) with a radius of 100, no labels
  # * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150)
  # This will draw a pie graph centered at (150-150) with a radius of 50 and percentages
  # * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,50,Rchart::PIE_PERCENTAGE)
  # This will draw a pie graph centered at (150-150) with a radius of 100, captions and slightly exploded
  # * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,100,Rchart::PIE_PERCENTAGE,4)

  def draw_flat_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=Rchart::PIE_NOLABEL,splice_distance=0,decimals=0,all_black=false)
    data_description = validate_data_description("draw_flat_pie_graph",data_description,false)
    validate_data("draw_flat_pie_graph",data)
    shadow_status = @shadow_active
    @shadow_active = false
    # Determine pie sum
    series = 0
    pie_sum = 0
    i_values = []
    r_values  = []
    i_labels  = []
    data_description["values"].each do|col_name|
      if (col_name != data_description["position"])
        series = series+1
        data.each do |key|
          if (!key[col_name].nil?)
            pie_sum = pie_sum + key[col_name]
            i_values << key[col_name]
            i_labels   << key[data_description["position"]]
          end
        end
      end
    end

    #Validate serie
    if ( series != 1 )
      raise_fatal("Pie chart can only accept one serie of data.")
      return -1
    end

    splice_ratio   = 360.0 / pie_sum
    splice_percent = 100.0 / pie_sum
    # Calculate all polygons
    angle = 0
    top_plots = []
    i_values.each_with_index do |value,key|
      x_offset = Math.cos((angle+(value*1.0/2*splice_ratio)) * Math::PI / 180 ) * splice_distance
      y_offset = Math.sin((angle+(value*1.0/2*splice_ratio)) * Math::PI / 180 ) * splice_distance

      top_plots[key] = [(x_pos + x_offset).round]
      top_plots[key] << (y_pos + y_offset).round
      if ( all_black )
        rc = @shadow_r_color
        gc = @shadow_g_color
        bc = @shadow_b_color
      else
        rc = @palette[key]["r"]
        gc = @palette[key]["g"]
        bc = @palette[key]["b"]
      end
      x_line_last = ""
      y_line_last = ""
      #	 Process labels position & size
      caption = ""
      if ( !(draw_labels == Rchart::PIE_NOLABEL) )
        t_angle   = angle+(value*splice_ratio/2)
        if (draw_labels == Rchart::PIE_PERCENTAGE)
          caption  = ((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        elsif (draw_labels == Rchart::PIE_LABELS)
          caption  = i_labels[key]
        elsif (draw_labels == Rchart::PIE_PERCENTAGE_LABEL)
          caption  = i_labels[key].to_s+"\r\n"+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
        end
        position   = image_ftb_box(@font_size,0,@font_name,caption)
        text_width  = position[2]-position[0]
        text_height = (position[1].abs)+(position[3].abs)

        tx = Math.cos((t_angle) * Math::PI / 180 ) * (radius+10+splice_distance) + x_pos
        if ( t_angle > 0 && t_angle < 180 )
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (radius+10+splice_distance) + y_pos + 4
        else
          ty = Math.sin((t_angle) * Math::PI / 180 ) * (radius+splice_distance+4) + y_pos - (text_height*1.0/2)
        end
        tx = tx - text_width if ( t_angle > 90 && t_angle < 270 )
        c_text_color = allocate_color(@picture,70,70,70)
        image_ttf_text(@picture,@font_size,0,tx,ty,c_text_color,@font_name,caption)
      end

      # Process pie slices
      if ( !all_black )
        line_color =allocate_color(@picture,rc,gc,bc)
      else
        line_color = allocate_color(@picture,rc,gc,bc)
      end
      x_line_last = ""
      y_line_last = ""
      i_angle=angle
      while(i_angle<=angle+value*splice_ratio)
        pos_x = Math.cos(i_angle * Math::PI / 180 ) * radius + x_pos + x_offset
        pos_y = Math.sin(i_angle * Math::PI / 180 ) * radius + y_pos + y_offset
        top_plots[key]<< (pos_x).round
        top_plots[key] << (pos_y).round
        if ( i_angle == angle || i_angle == angle+value*splice_ratio || i_angle+0.5 > angle+value*splice_ratio)
          draw_line(x_pos+x_offset,y_pos+y_offset,pos_x,pos_y,rc,gc,bc)
        end
        if ( x_line_last != "" )
          draw_line(x_line_last,y_line_last,pos_x,pos_y,rc,gc,bc)
        end
        x_line_last = pos_x
        y_line_last = pos_y
        i_angle=i_angle+0.5
      end

      top_plots[key] << (x_pos + x_offset).round
      top_plots[key]<< (y_pos + y_offset).round
      angle = i_angle
    end
    poly_plots = top_plots
    # Draw Top polygons
    poly_plots.each_with_index do  |value,key|
      if ( !all_black )
        image_filled_polygon(@picture,poly_plots[key],@palette[key]["r"],@palette[key]["g"],@palette[key]["b"])
      else
        image_filled_polygon(@picture,poly_plots[key],@shadow_r_color,@shadow_g_color,@shadow_b_color)
      end
    end
    @shadow_active = shadow_status

  end
end
