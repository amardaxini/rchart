module CubicChart
# This function will draw a curved line graph using all the registered series.
  # This curve is using a cubic algorithm to process the average values between two points.
  # You have to specify the accuracy between two points, typically a 0.1 value is acceptable. the smaller the value is, the longer it will take to process the graph.
  def draw_cubic_curve(data,data_description,accuracy=0.1,serie_name="")

    data_description = self.validate_data_description("draw_cubic_curve",data_description)
    self.validate_data("draw_cubic_curve",data)
    graph_id = 0
    id = 0
    color_id =0

    data_description["values"].each do |col_name|
      if ( serie_name == "" || serie_name == col_name )
        x_in = []
        y_in =[]
        y_t = []
        u = []
        x_in[0] = 0
        y_in[0] = 0

        data_description["description"].each do |key_i,value_i|
          if ( key_i == col_name )
            color_id = id
            id = id+1
          end
        end
        index = 1
        x_last = -1
        missing = []
        data.each do |key|
          if(!key[col_name].nil?)
            val = key[col_name]

            x_in[index]  = index
            #y_in[index] =  val
            #my hack TODO "" convet missing values to zero
            y_in[index] =  val if ((val).is_a?(Numeric))
            y_in[index] = 0 if (!(val).is_a?(Numeric))
            ######
            missing[index]=true if (!(val).is_a?(Numeric))
            index=index+1
          end
        end
        index= index-1
        y_t[0] = 0
        y_t[1] = 0
        u[0] = 0
        u[1]  = 0
        i =2
        y_last =0

        while(i<=index-1)
          sig = (x_in[i]-x_in[i-1])*1.0/(x_in[i+1]-x_in[i-1]) #rescue 0
          p=sig*y_t[i-1]+2
          y_t[i]=(sig-1)/p
          u[i]=(y_in[i+1]-y_in[i])*1.0/(x_in[i+1]-x_in[i])-(y_in[i]-y_in[i-1])*1.0/(x_in[i]-x_in[i-1]) #rescue 0
          u[i]=(6*u[i]/(x_in[i+1]-x_in[i-1])-sig*u[i-1])/p #rescue 0
          i=i+1
        end
        qn = 0
        un = 0
        y_t[index] = (un - qn * u[index-1]) / (qn * y_t[index-1] + 1)
        k = index-1
        while k>=1
          y_t[k]=y_t[k]*	y_t[k+1]+u[k]
          k=k-1
        end
        x_pos  = @g_area_x1 + @g_area_x_offset
        x =1
        while x<=index
          klo=1
          khi=index
          k = khi-klo
          while k>1
            k=khi-klo
            if x_in[k]>=x
              khi=k
            else
              klo=k
            end
          end
          klo=khi-1
          h = x_in[khi]-x_in[klo]
          a = (x_in[khi]-x)/h rescue 1
          b = (x-x_in[klo])/h rescue 1
          value = a*y_in[klo]+b*y_in[khi]+((a*a*a-a)*y_t[klo]+(b*b*b-b)*y_t[khi])*(h*h)/6
          y_pos = @g_area_y2-((value-@vmin)*@division_ratio)
          #TODO Check(x_last!=-1 && !missing[x.floor].nil? && !missing[(x+1).floor].nil? )
          #UPDATED
          if (x_last!=-1 && missing[x.floor].nil? && missing[(x+1).floor].nil? )
            self.draw_line(x_last,y_last,x_pos,y_pos, @palette[id]["r"],@palette[id]["g"],@palette[id]["b"],true)
          end
          x_last = x_pos
          y_last = y_pos
          x_pos = x_pos +@division_width*accuracy
          x=x+accuracy
        end
        #Add potentialy missing values
        x_pos  = x_pos - @division_width * accuracy
        if ( x_pos < (@g_area_x2 - @g_area_x_offset) )
          y_pos = @g_area_y2 - ((y_in[index]-@vmin) * @division_ratio)
          self.draw_line(x_last,y_last,@g_area_x2-@g_area_x_offset,y_pos,@palette[id]["r"],@palette[id]["g"],@palette[id]["b"],true)
        end
        graph_id += 1
      end
    end
  end
  # This function will draw a filled curved line graph using all the registered series.
  # This curve is using a cubic algorythm to process the average values between two points.
  # You have to specify the accuracy between two points, typicaly a 0.1 value is acceptable. the smaller the value is, the longer it will take to process the graph.
  # You can provide the alpha value used when merging all series layers.
  # If around_zero is set to true, the area drawn will be between the 0 axis and the line graph value.

  def draw_filled_cubic_curve(data,data_description,accuracy=0.1,alpha=100,around_zero=false)
    data_description = self.validate_data_description("draw_filled_cubic_curve",data_description)
    self.validate_data("draw_filled_cubic_curve",data)
    layer_width  = @g_area_x2-@g_area_x1
    layer_height = @g_area_y2-@g_area_y1
    y_zero = layer_height - ((0-@vmin) * @division_ratio)
    y_zero = layer_height if ( y_zero > layer_height )
    graph_id = 0
    id = 0
    color_id =0
    data_description["values"].each do |col_name|
      x_in = []
      y_in =[]
      y_t = []
      u = []
      x_in[0] = 0
      y_in[0] = 0
      data_description["description"].each do |key_i,value_i|
        if ( key_i == col_name )
          color_id = id
          id = id+1
        end
      end
      index = 1
      x_last = -1
      missing = []
      data.each do |key|
        if(!key[col_name].nil?)
          val = key[col_name]
          x_in[index]  = index
          y_in[index] =  val
          missing[index]=true if ((val).is_a?(Numeric))
          index=index+1
        end
      end
      index= index-1
      y_t[0] = 0
      y_t[1] = 0
      u[1]  = 0
      i =2
      y_last =0

      while(i<index)
        sig = (x_in[i]-x_in[i-1])*1.0/(x_in[i+1]-x_in[i-1]) #rescue 0
        p=sig*y_t[i-1]+2
        y_t[i]=(sig-1)/p
        u[i]=(y_in[i+1]-y_in[i])*1.0/(x_in[i+1]-x_in[i])-(y_in[i]-y_in[i-1])*1.0/(x_in[i]-x_in[i-1]) #rescue 0
        u[i]=(6*u[i]/(x_in[i+1]-x_in[i-1])-sig*u[i-1])/p #rescue 0
        i=i+1
      end
      qn = 0
      un = 0
      y_t[index] = (un - qn * u[index-1]) / (qn * y_t[index-1] + 1)
      k = index-1
      while k>=1
        y_t[k]=y_t[k]*	y_t[k+1]+u[k]
        k=k-1
      end
      points = []
      points << @g_area_x_offset
      points << layer_height
      @layers[0] = image_create_true_color(layer_width,layer_height)
      image_filled_rectangle(@layers[0],0,0,layer_width,layer_height, 255,255,255)
      image_color_transparent(@layers[0], 255,255,255)
      y_last = nil
      x_pos  = @g_area_x_offset
      points_count= 2
      x=1
      while(x<=index)
        klo=1
        khi=index
        k = khi-klo
        while k>1
          k=khi-klo
          if x_in[k]>=x
            khi=k
          else
            klo=k
          end
        end
        klo=khi-1
        h = x_in[khi]-x_in[klo]
        a = (x_in[khi]-x)/h rescue 1
        b = (x-x_in[klo])/h rescue 1
        value = a*y_in[klo]+b*y_in[khi]+((a*a*a-a)*y_t[klo]+(b*b*b-b)*y_t[khi])*(h*h)/6
        y_pos = layer_height - ((value-@vmin) * @division_ratio)

        a_points  = []
        if ( !y_last.nil? && around_zero && (missing[x.floor].nil?) && (missing[(x+1).floor].nil?))

          a_points << x_last
          a_points << y_last
          a_points << x_pos
          a_points << y_pos
          a_points << x_pos
          a_points << y_zero
          a_points << x_last
          a_points << y_zero
          #check No of points here 4 is pass check in image filled_polygon
          image_filled_polygon(@layers[0], a_points, @palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],4)
        end
        if ( missing[(x.floor)].nil? || y_last.nil?)
          points_count = points_count+1
          points << x_pos
          points << y_pos
        else
          points_count = points_count+1
          points << x_last
          points << y_last
        end
        y_last = y_pos
        x_last = x_pos
        x_pos  = x_pos + @division_width * accuracy
        x=x+accuracy
      end

      #// Add potentialy missing values
      # a_points  = []
      x_pos  = x_pos - @division_width * accuracy
      if ( x_pos < (layer_width-@g_area_x_offset) )
        y_pos = layer_height - ((y_in[index]-@vmin) * @division_ratio)
        if ( !y_last.nil? && around_zero )
          a_points << x_last
          a_points <<  y_last
          a_points << (layer_width-@g_area_x_offset)
          a_points << y_pos
          a_points << (layer_width-@g_area_x_offset)
          a_points << y_zero
          a_points <<  x_last
          a_points << y_zero
          #  imagefilledpolygon(@layers[0],a_points,4,$C_Graph)
          image_filled_polygon(@layers[0], a_points, @palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],4)
        end

        if ( y_in[klo] != "" && y_in[khi] != "" || y_last.nil? )

          points_count +=1
          points << (layer_width-@g_area_x_offset).floor
          points << (y_pos).floor
        end
      end

      points << (layer_width-@g_area_x_offset).floor
      points << layer_height.floor

      if ( !around_zero )
        image_filled_polygon(@layers[0], points, @palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],points_count)
      end

      image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
      image_destroy(@layers[0])

      	draw_cubic_curve(data, data_description,accuracy,col_name)
      graph_id+=1
    end
  end
end
