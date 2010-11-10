module GraphHelper
  # This function can be used to set the background color.
  # The default graph background color is set to white.
  def draw_background(r,g,b)
    b,g,r= validate_color(b, g, r)
    image_filled_rectangle(@picture,0,0,@x_size,@y_size,r,g,b)
  end

  # You can use this function to fill the background of the picture or of the graph area with a color gradient pattern.
  # You must specify the starting color with its r,g,b values, the number of shades to apply with the decay parameter and optionnaly the target that can be :
  # * Rchart:: TARGET_GRAPHAREA The currently defined graph area
  # * Rchart:: TARGET_BACKGROUND The whole picture background
  def draw_graph_area_gradient(r,g,b,decay,target=Rchart::TARGET_GRAPHAREA)
    b, g, r = validate_color(b, g, r)
    x1,y1,x2,y2 = 0,0,0,0
    if ( target == Rchart::TARGET_GRAPHAREA )
      x1 = @g_area_x1+1
      x2 = @g_area_x2-1
      y1 = @g_area_y1+1
      y2 = @g_area_y2
    end

    if ( target == Rchart::TARGET_BACKGROUND )
      x1 = 0
      x2 = @x_size
      y1 = 0
      y2 = @y_size
    end
    #Positive gradient
    if ( decay > 0 )
      y_step = (y2 - y1 - 2) / decay
      i=0
      while i<=decay
        r-=1
        g-=1
        b-=1
        yi1 = y1 + ( i * y_step )
        yi2 = ( yi1 + ( i * y_step ) + y_step ).ceil
        yi2 = y2-1 if ( yi2 >= yi2 )
        image_filled_rectangle(@picture,x1,yi1,x2,yi2,r,g,b)
        i=i+1
      end
    end
    # Negative gradient
    if ( decay < 0 )
      y_step = (y2 - y1 - 2) / -decay
      yi1   = y1
      yi2   = y1+y_step
      i= -decay
      while i>=0
        r+=1
        g+=1
        b+=1
        image_filled_rectangle(@picture,x1,yi1,x2,yi2,r,g,b)
        yi1+= y_step
        yi2+= y_step
        yi2 = y2-1 if ( yi2 >= yi2 )
        i= i-1
      end

    end
  end

  # This function draw an aliased rectangle
  # The upper left and bottom right border positions are used as first 4 arguments.
  # The last 3 parameters are used to set the border color
  def draw_rectangle(x1, y1, x2, y2, r, g, b)
    b, g, r = validate_color(b, g, r)
    c_rectangle =  allocate_color(@picture,r, g, b)
    x1=x1-0.2
    y1=y1-0.2
    x2=x2+0.2
    y2=y2+0.2
    draw_line(x1,y1,x2,y1,r,g,b)
    draw_line(x2,y1,x2,y2,r,g,b)
    draw_line(x2,y2,x1,y2,r,g,b)
    draw_line(x1,y2,x1,y1,r,g,b)
  end

  # This function draw an aliased filled rectangle
  # The upper left and bottom right border positions are used as first 4 arguments. The last R,G,B parameters are used to set the border color.
  # You can specify if the aliased border will be drawn and the transparency.
  def draw_filled_rectangle(x1, y1, x2, y2, r, g, b, draw_border=true, alpha=100,no_fall_back=false)
    x1, x2 = x2, x1  if x2.to_f < x1.to_f
    y1, y2 = y2, y1   if y2.to_f < y1.to_f
    b,g,r=validate_color(b, g, r)

    if(alpha == 100)
      #Process shadows
      if(@shadow_active && no_fall_back)
        draw_filled_rectangle(x1+@shadow_x_distance,y1+@shadow_y_distance,x2+@shadow_x_distance,y2+@shadow_y_distance,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha,true)
        if(@shadow_blur != 0)
          alpha_decay = (@shadow_alpha/ @shadow_blur)
          i =1
          while i<=@shadow_blur
           draw_filled_rectangle(x1+@shadow_x_distance-i/2,y1+@shadow_y_distance-i/2,x2+@shadow_x_distance-i/2,y2+@shadow_y_distance-i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha-alpha_decay*i,true)
            i = i+1
          end
          i = 1
          while i<=@shadow_blur
           draw_filled_rectangle(x1+@shadow_x_distance+i/2,y1+@shadow_y_distance+i/2,x2+@shadow_x_distance+i/2,y2+@shadow_y_distance+i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha-alpha_decay*i,true)
            i = i+1
          end
        end
      end
      image_filled_rectangle(@picture,x1.to_f.round,y1.to_f.round,x2.to_f.round,y2.to_f.round,r,g,b)
    else
      layer_width  = (x2-x1).abs+2
      layer_height = (y2-y1).abs+2
      @layers[0] = image_create_true_color(layer_width,layer_height)
      c_white  = allocate_color(@layers[0],255,255,255)
      image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
      image_color_transparent(@layers[0],255,255,255)
      image_filled_rectangle(@layers[0],1.round,1.round,(layer_width-1).round,(layer_height-1).round,r,g,b)
      image_copy_merge(@layers[0],@picture,([x1,x2].min-1).round,([y1,y2].min-1).round,0,0,layer_width,layer_height,alpha)
      #TODO Find out equivalent method
      image_destroy(@layers[0])
    end
    if (draw_border )
      shadow_settings = @shadow_active
      @shadow_active = false
      draw_rectangle(x1,y1,x2,y2,r,g,b)
      @shadow_active = shadow_settings
    end
  end

  # This function draw an aliased rectangle with rounded corners
  # The upper left and bottom right border positions are used as first 4 arguments.
  # Argument #5 represents the radius of the rounded corner.
  # The last 3 parameters are used to set the border color.
  def draw_rounded_rectangle(x1, y1, x2, y2, radius,r, g, b)
    b, g, r = validate_color(b, g, r)

    c_rectangle = allocate_color(@picture,r,g,b)

    step = 90 / ((3.1418 * radius)/2)
    i=0
    while i<=90
      x = Math.cos((i+180)*3.1418/180) * radius + x1 + radius
      y = Math.sin((i+180)*3.1418/180) * radius + y1 + radius
     draw_antialias_pixel(x,y,r,g,b)

      x = Math.cos((i-90)*3.1418/180) * radius + x2 - radius
      y = Math.sin((i-90)*3.1418/180) * radius + y1 + radius
      draw_antialias_pixel(x,y,r,g,b)

      x = Math.cos((i)*3.1418/180) * radius + x2 - radius
      y = Math.sin((i)*3.1418/180) * radius + y2 - radius
      draw_antialias_pixel(x,y,r,g,b)

      x = Math.cos((i+90)*3.1418/180) * radius + x1 + radius
      y = Math.sin((i+90)*3.1418/180) * radius + y2 - radius
      draw_antialias_pixel(x,y,r,g,b)
      i=i+step
    end

    x1=x1-0.2
    y1=y1-0.2
    x2=x2+0.2
    y2=y2+0.2
    draw_line(x1+radius,y1,x2-radius,y1,r,g,b)
    draw_line(x2,y1+radius,x2,y2-radius,r,g,b)
    draw_line(x2-radius,y2,x1+radius,y2,r,g,b)
    draw_line(x1,y2-radius,x1,y1+radius,r,g,b)
  end
  # This function draw an aliased filled rectangle with rounded corners
  # The upper left and bottom right border positions are used as first 4 arguments.
  # Argument #5 represents the radius of the rounded corner.
  # The last 3 parameters are used to set the border color.
  def draw_filled_rounded_rectangle(x1, y1, x2, y2, radius,r, g, b, draw_border=true, alpha=100)
    b, g, r = validate_color(b, g, r)
    c_rectangle = allocate_color(@picture,r,g,b)

    step = 90 / ((3.1418 * radius)/2)
    i=0
    while i<=90
      xi1 = Math.cos((i+180)*3.1418/180) * radius + x1 + radius
      yi1 = Math.sin((i+180)*3.1418/180) * radius + y1 + radius

      xi2 = Math.cos((i-90)*3.1418/180) * radius + x2 - radius
      yi2 = Math.sin((i-90)*3.1418/180) * radius + y1 + radius

      xi3 = Math.cos((i)*3.1418/180) * radius + x2 - radius
      yi3 = Math.sin((i)*3.1418/180) * radius + y2 - radius

      xi4 = Math.cos((i+90)*3.1418/180) * radius + x1 + radius
      yi4 = Math.sin((i+90)*3.1418/180) * radius + y2 - radius

      image_line(@picture,xi1,yi1,x1+radius,yi1,r,g,b)
      image_line(@picture,x2-radius,yi2,xi2,yi2,r,g,b)
      image_line(@picture,x2-radius,yi3,xi3,yi3,r,g,b)
      image_line(@picture,xi4,yi4,x1+radius,yi4,r,g,b)

      draw_antialias_pixel(xi1,yi1,r,g,b)
      draw_antialias_pixel(xi2,yi2,r,g,b)
      draw_antialias_pixel(xi3,yi3,r,g,b)
      draw_antialias_pixel(xi4,yi4,r,g,b)
      i=i+step
    end
    image_filled_rectangle(@picture,x1,y1+radius,x2,y2-radius,r,g,b)
    image_filled_rectangle(@picture,x1+radius,y1,x2-radius,y2,r,g,b)

    x1=x1-0.2
    y1=y1-0.2
    x2=x2+0.2
    y2=y2+0.2
    draw_line(x1+radius,y1,x2-radius,y1,r,g,b)
    draw_line(x2,y1+radius,x2,y2-radius,r,g,b)
    draw_line(x2-radius,y2,x1+radius,y2,r,g,b)
    draw_line(x1,y2-radius,x1,y1+radius,r,g,b)
  end
  # This function draw an aliased circle at position (xc,yc) with the specified radius.
  # The last 3 parameters are used to set the border color.
  # Width is used to draw ellipses.
  def draw_circle(xc,yc,height,r,g,b,width=0)
    width = height if ( width == 0 )
    b, g, r = validate_color(b, g, r)

    c_circle = allocate_color(@picture,r,g,b)
    step     = 360 / (2 * 3.1418 * [width,height].max)
    i =0
    while(i<=360)
      x= Math.cos(i*3.1418/180) * height + xc
      y = Math.sin(i*3.1418/180) * width + yc
      draw_antialias_pixel(x,y,r,g,b)
      i = i+step
    end
  end

  # This function draw a filled aliased circle at position (xc,yc) with the specified radius.
  # The last 3 parameters are used to set the border and filling color.
  # Width is used to draw ellipses.
  def draw_filled_circle(xc,yc,height,r,g,b,width=0)
    width = height if ( width == 0 )
    b, g, r = validate_color(b, g, r)
    step     = 360 / (2 * 3.1418 * [width,height].max)
    i =90
    while i<=270
      x1 = Math.cos(i*3.1418/180) * height + xc
      y1 = Math.sin(i*3.1418/180) * width + yc
      x2 = Math.cos((180-i)*3.1418/180) * height + xc
      y2 = Math.sin((180-i)*3.1418/180) * width + yc
      draw_antialias_pixel(x1-1,y1-1,r,g,b)
      draw_antialias_pixel(x2-1,y2-1,r,g,b)
      image_line(@picture,x1,y1-1,x2-1,y2-1,r,g,b) if ( (y1-1) > yc - [width,height].max )
      i= i+step
    end
  end

  # This function draw an aliased ellipse at position (xc,yc) with the specified height and width.
  # The last 3 parameters are used to set the border color.
  def draw_ellipse(xc,yc,height,width,r,g,b)
    draw_circle(xc,yc,height,r,g,b,width)
  end


  # This function draw a filled aliased ellipse at position (xc,yc) with the specified height and width.
  # The last 3 parameters are used to set the border and filling color.
  def draw_filled_ellipse(xc,yc,height,width,r,g,b)
    draw_filled_circle(xc,yc,height,r,g,b,width)
  end

  # This function will draw an aliased line between points (x1,y1) and (x2,y2).
  # The last 3 parameters are used to set the line color.
  # The last optional parameter is used for internal calls made by graphing function.If set to true, only portions of line inside the graph area will be drawn.

  def draw_line(x1,y1,x2,y2,r,g,b,graph_function=false)
    if ( @line_dot_size > 1 )
      draw_dotted_line(x1,y1,x2,y2,@line_dot_size,r,g,b,graph_function)
    else
      b, g, r = validate_color(b, g, r)
      distance = Math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)) rescue 0
      if ( distance == 0 )
        return -1
      else
        x_step = (x2-x1) / distance
        y_step = (y2-y1) / distance
        i =0
        while i<=distance
          x = i * x_step + x1
          y = i * y_step + y1
          if((x >= @g_area_x1.to_f && x <= @g_area_x2.to_f && y >= @g_area_y1.to_f && y <= @g_area_y2.to_f) || !graph_function )
            if ( @line_width == 1 )
              draw_antialias_pixel(x,y,r,g,b)
            else
              start_offset = -(@line_width/2)
              end_offset = (@line_width/2)
              j = start_offset

              while j<=end_offset
                draw_antialias_pixel(x+j,y+j,r,g,b)
                j+=1
              end
            end
          end
          i =i+1
        end
      end
    end
  end
  # This function will draw an alpha pixel at position (x,y).
  # alpha is used to specify the transparency factor ( between 0 and 100 )
  # The last 3 parameters are used to set the pixel color.
  def draw_alpha_pixel(x,y,alpha,r,g,b)
    b, g, r = validate_color(b, g, r)
    if ( x < 0 || y < 0 || x >= @x_size || y >= @y_size )
      #eturn(-1)
      #TODO check image_color_at method is right?
    else
      rgb2= image_color_at(@picture, x, y)
      r2   = (rgb2 >> 16) & 0xFF
      g2   = (rgb2 >> 8) & 0xFF
      b2   = rgb2 & 0xFF
      i_alpha = (100 - alpha)/100
      alpha  = alpha / 100
      ra   = (r*alpha+r2*i_alpha).floor
      ga   = (g*alpha+g2*i_alpha).floor
      ba   = (b*alpha+b2*i_alpha).floor
      image_set_pixel(@picture,x,y,ra,ga,ba)
    end
  end

  # This function will draw an aliased dotted line between points (x1,y1) and (x2,y2).
  # Parameter #5 is used to specify the dot size ( 2 will draw 1 point every 2 points )
  # The last 3 parameters are used to set the line color.
  def draw_dotted_line(x1,y1,x2,y2,dot_size,r,g,b,graph_function=false)
    b, g, r = validate_color(b, g, r)
    distance = Math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
    x_step = (x2-x1) / distance
    y_step = (y2-y1) / distance
    dot_index = 0
    i = 0
    start_offset = 0

    while(i<=distance)
      x = i * x_step  + x1
      y = i * y_step + y1
      if ( dot_index <= dot_size)
        if ( (x >= @g_area_x1 && x <= @g_area_x2 && y >= @g_area_y1 && y <= @g_area_y2) || !graph_function )
          if (@line_width == 1 )
            draw_antialias_pixel(x,y,r,g,b)
          else
            start_offset = start_offset -(@line_width/2)
            end_offset = (@line_width/2)
            j = start_offset
            while(j<= end_offset)
              draw_antialias_pixel(x+j,y+j,r,g,b)
              j= j+1
            end
          end
        end
      end
      dot_index = dot_index+1
      dot_index = 0 if (dot_index == dot_size * 2)
      i= i+1
    end

  end
# Private functions for internal processing Internal function.
  def draw_antialias_pixel(x,y,r,g,b,alpha=100,no_fall_back=false)
    #Process shadows
    if(@shadow_active && !no_fall_back)
      draw_antialias_pixel(x+@shadow_x_distance,y+@shadow_y_distance,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha,true)
      if(@shadow_blur != 0)
        alpha_decay = (@shadow_alpha*1.0 / @shadow_blur)
        i=1
        while i<=@shadow_blur
          draw_antialias_pixel(x+@shadow_x_distance-i/2,y+@shadow_y_distance-i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha-alpha_decay*i,true)
          i = i+1
        end
        i =1
        while i<=@shadow_blur
          draw_antialias_pixel(x+@shadow_x_distance+i/2,y+@shadow_y_distance+i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha-alpha_decay*i,true)
          i = i+1
        end
      end
    end
    b, g, r = validate_color(b, g, r)
    plot = ""
    xi   = x.floor rescue 0
    yi   = y.floor rescue 0
    if ( xi == x && yi == y)
      if ( alpha == 100 )
        image_set_pixel(@picture,x,y,r,g,b)
      else
        draw_alpha_pixel(x,y,alpha,r,g,b)
      end
    else
      if xi > 0 || yi > 0 #soe error occures therefor added condtion
        alpha1 = (((1 - (x - x.floor)) * (1 - (y - y.floor)) * 100) / 100) * alpha
        draw_alpha_pixel(xi,yi,alpha1,r,g,b) if alpha1 > @anti_alias_quality
        alpha2 = (((x -  x.floor) * (1 - (y - y.floor)) * 100) / 100) * alpha
        draw_alpha_pixel(xi+1,yi,alpha2,r,g,b) if alpha2 > @anti_alias_quality
        alpha3 = (((1 - (x -  x.floor)) * (y - y.floor) * 100) / 100) * alpha
        draw_alpha_pixel(xi,yi+1,alpha3,r,g,b) if alpha3 > @anti_alias_quality
        alpha4 = (((x -  x.floor) * (y - y.floor) * 100) / 100) * alpha
        draw_alpha_pixel(xi+1,yi+1,alpha4,r,g,b)  if alpha4 > @anti_alias_quality
      end
    end
  end

  # Activate the image map creation process Internal function
  def set_image_map(mode=true,graph_id="MyGraph")
    @build_map = mode
    @map_id    = graph_id
  end
  # Add a box into the image map Internal function
  def add_to_image_map(x1,y1,x2,y2,serie_name,value,caller_function)
    if ( @map_function == nil || @map_function == caller_function )
      @image_map  << (x1.round).to_s+","+(y1.round).to_s+","+(x2.round).to_s+","+(y2.round).to_s+","+serie_name+","+value.to_s
      @map_function = caller_function
    end
  end
end
