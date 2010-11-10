
module RchartHelper

  # Set font Properties font_name,font_size
  # font_name is
  # * GeosansLight.ttf,
  # * MankSans.ttf,
  # * pf_arma_five.ttf,
  # * Silkscreen.ttf,
  # * tahoma.ttf
  def set_font_properties(font_name, font_size)
    @font_size = font_size
    @font_name = "#{Rchart::FONT_PATH}/#{font_name}"
  end

  def validate_color(b, g, r)
    r = 0    if ( r < 0 )
    r = 255  if ( r > 255 )
    g = 0    if ( g < 0 )
    g = 255  if ( g > 255 )
    b = 0    if ( b < 0 )
    b = 255  if ( b > 255 )
    return b, g, r
  end
  #color Helper
  def allocate_color(picture,r,g,b,factor=0)
    r = r + factor
    g = g + factor
    b = b + factor
    b,g,r= validate_color(b,g,r)
    image_color_allocate(picture,r,g,b)
  end

#Use this function to set shadow properties.
  def set_shadow_properties(x_distance=1,y_distance=1,r=60,g=60,b=60,alpha=50,blur=0)
    @shadow_active    = true
    @shadow_x_distance = x_distance
    @shadow_y_distance = y_distance
    @shadow_r_color    = r
    @shadow_g_color    = g
    @shadow_b_color    = b
    @shadow_alpha     = alpha
    @shadow_blur      = blur
  end

  # Use this function to deactivate the shadow options.
  # Drawing shadows is time and CPU intensive.
  def clear_shadow
    @shadow_active = false
  end


  # This function allow you to customise the way lines are drawn in charts.
  # This function only applies during chart drawing calls ( line charts,.. ).
  # You can specify the width of the lines & if they are dotted.
  def set_line_style(width=1,dot_size=0)
    @line_width = width
    @line_dot_size = dot_size
  end

  # Set currency symbol
  def set_currency(currency)
    @currency = currency
  end
  # This function allows you to merge an external PNG picture with your graph specifying the position and the transparency
  def draw_from_png(file_name,x,y,alpha=100)
    draw_from_picture(1,file_name,x,y,alpha)
  end

  #This function allows you to merge an external GIF picture with your graph specifying the position and the transparenc
  #def draw_from_gif(file_name,x,y,alpha=100)
  #self.draw_from_picture(2,file_name,x,y,alpha)
  #end

  # This function allows you to merge an external JPG picture with your graph specifying the position and the transparency.
  def draw_from_jpg(file_name,x,y,alpha=100)
    draw_from_picture(3,file_name,x,y,alpha)
  end

  # Generic loader function for external pictures accepts png format
  def draw_from_picture(pic_type,file_name,x,y,alpha=100)
    if ( File.exist?(file_name))
      raster = image_create_from_png(file_name) if ( pic_type == 1 )
      # raster = image_create_from_gif(file_name) if ( pic_type == 2 )
      raster = image_create_from_jpeg(file_name) if ( pic_type == 3 )
      infos  = get_image_size(raster)
      width  = infos[0]
      height = infos[1]
      image_copy_merge(raster,@picture,x,y,0,0,width,height,alpha)
      image_destroy(raster)
    end
  end


# Validate data contained in the description array  Internal function
  def validate_data_description(function_name,data_description,description_required=true)
    if (data_description["position"].nil?)
      @errors  << "[Warning] #{function_name} - Y Labels are not set."
      data_description["position"] = "name"
    end

    if (description_required)
      if ((data_description["description"].nil?))
        @errors  << "[Warning] #{function_name} - Series descriptions are not set."
        data_description["values"].each do |value|
          if data_description["description"].nil?
            data_description["description"]={value=> value}
          else
            data_description["description"]=data_description["description"].merge(value=>value)
          end
        end
      end

      data_desc_count = data_description["values"].is_a?(Array) ? data_description["values"].count : 1
      if ((data_description["description"].count) < data_desc_count)
        @errors << "[Warning] #{function_name} - Some series descriptions are not set."
        data_description["values"].each do |value|
          data_description["description"][value] = value  if ( data_description["description"][value].nil?)
        end
      end
    end
    return data_description
  end
  #Validate data contained in the data array Internal function
  def validate_data(function_name,data)
    data_summary = {}
    data.each do |v|
      v.each do |key,val|

        if (data_summary[key].nil?)
          data_summary[key] = 1
        else
          data_summary[key] = data_summary[key]+1
        end
      end
    end
    if ( data_summary.max.last == 0 ) #TODO Check method
      @errors << "[Warning]  #{function_name} No data set."
    end
    data_summary.each do |k,v|
      if v < data_summary.max.last
        @errors << "#{function_name} Missing Data in serie #{key}"
      end
    end
    return data
  end
  #Convert seconds to a time format string
  def to_time(value)
    hour   = (value/3600).floor
    minute = ((value - hour*3600)/60).floor
    second =(value - hour*3600 - minute*60).floor

    hour = "0.#{Hour}"  if (hour.length == 1 )
    minute = "0.#{minute}"    if (minute.length == 1 )
    second = "0.#{second}"  if (second.length == 1 )

    return ("#{hour}.:.#{minute}}.:.#{second}")
  end

  # Convert to metric system */
  def to_metric(value)
    go = (value/1000000000).floor
    mo = ((value - go*1000000000)/1000000).floor
    ko = ((value - go*1000000000 - mo*1000000)/1000).floor
    o  = (value - go*1000000000 - mo*1000000 - ko*1000).floor

    return("#{go}..#{mo}.g")   if (go != 0)
    return("#{mo}...#{ko}.m")   if (mo != 0)
    return("#{ko}...#{o}).k")   if (ko != 0)
    return o
  end

# Convert to curency
  def to_currency(value)
    go = (value/1000000000).floor
    mo = ((value - go*1000000000)/1000000).floor
    ko = ((value - go*1000000000 - mo*1000000)/1000).floor
    o  = (value - go*1000000000 - mo*1000000 - ko*1000).floor

    o = "00.#{o}"  if ( (o.length) == 1 )
    o = "0.#{o}"   if ( (o.length) == 2 )

    result_string = o
    result_string = "#{ko}...#{result_string}"   if ( ko != 0 )
    result_string = "#{mo}...#{result_string}"   if ( mo != 0 )
    result_string = "#{go}...#{result_string}"   if ( go != 0 )

    result_string = @currency.result_string
    result_string
  end
  # Set date format for axis labels TODO
  def set_date_format(format)
    @date_format = format
  end

  def to_date(value)
    #return(Time.parse(value))
  end
  #	Check if a number is a full integer (for scaling)
  def is_real_int(value)
    value.ceil == value.floor
  end
  # round of particular decimal
  def round_of(no,n=0)
    (no * (10.0 ** n)).round * (10.0 ** (-n))
  end

  #convert degree to radian
  def deg2rad(deg)
    deg*Math::PI/180
  end

  def raise_fatal(message)
    puts "[FATAL] "+message
    return -1
  end
  # Print all error messages on the CLI or graphically
  def print_errors(mode="cli")
    return(0) if (@errors.count == 0)

    if mode == "cli"
      @errors.each do |value|
        puts value
      end
    elsif ( mode == "gd" )
      set_line_style(width=1)
      max_width = 0
      @errors.each do |value|
        position  = image_ftb_box(@error_font_size,0,@error_font_name,value)
        text_width = position[2]-position[0]
        max_width = text_width if ( text_width > max_width )
      end
      draw_filled_rounded_rectangle(@x_size-(max_width+20),@y_size-(20+((@error_font_size+4)*(@errors.count))),@x_size-10,@y_size-10,6,233,185,185)
      draw_rounded_rectangle(@x_size-(max_width+20),@y_size-(20+((@error_font_size+4)*(@errors.count))),@x_size-10,@y_size-10,6,193,145,145)
      c_text_color = allocate_color(@picture,133,85,85)
      ypos        = @y_size - (18 + ((@errors.count)-1) * (@error_font_size + 4))
      @errors.each do |value|
        image_ttf_text(@picture,@error_font_size,0,@x_size-(max_width+15),ypos,c_text_color,@error_font_name,value)
        ypos = ypos + (@error_font_size + 4)
      end
    end
  end
  
  # resize image on passing png,jpeg,or gd image
  # pass file_name/gd image,new_file_name,percentage,or resize width,resize height
  def resize_image(file_name,resize_file_name="test",resized_width=0,resized_height=0,render_file_as="png")
    image = Image.import(file_name)
    resize_image = image.resize(resized_width, resized_height,true)

    file=File.new(resize_file_name,"wb")
    if render_file_as == "png"
      file.write resize_image.png
    elsif	 render_file_as == "jpeg"
      file.write resize_image.jpeg
    elsif	 render_file_as == "gd"
      file.write resize_image.gd
    elsif	 render_file_as == "gd2"
      file.write resize_image.gd2
    else
      puts "Provide proper image"
    end
    file.close
  end

end
