module ColorPalette
  # This function can be used to change the color of one series.
  # series id are starting at 0 for associated data serie #1.
  # You must provide an rgb color.
  def set_color_palette(id,r,g,b)
    b,g,r=validate_color(b, g, r)
    @palette[id]["r"] = r
    @palette[id]["g"] = g
    @palette[id]["b"] = b
  end

  # Create a color palette shading from one color to another
  # This function will fill the color palette with 10 shades between the two RGB colors 0,0,0 and 100,100,100.This will produce grey shades. (Palette id 0-9 will be filled)
  def create_color_gradient_palette(r1,g1,b1,r2,g2,b2,shades)
    r_factor = (r2-r1)/shades
    g_factor = (g2-g1)/shades
    b_factor = (b2-b1)/shades
    i= 0
    while(i<= shades-1)
      @palette[i]["r"] = r1+r_factor*i
      @palette[i]["g"] = g1+g_factor*i
      @palette[i]["b"] = b1+b_factor*i
      i = i+1
    end
  end
  # This function will load the color scheme from a text file.
  # This file must be formatted with three values per line ( r,g,b ).
  # By default the delimiter is a coma but you can specify it.
  def load_color_palette_from_file(file_name)
    color_id = 0
    File.open(file_name,"r") do |infile|
      while (line = infile.gets)
        values = line.split(",")
        if ( values.length == 3 )
          @palette[color_id]["r"] = values[0].to_i
          @palette[color_id]["g"] = values[1].to_i
          @palette[color_id]["b"] = values[2].to_i
          color_id+=1
        end
      end
    end
  end

  # Load palette from array [[r,g,b],[r1,g1,b1]]
  def load_color_palette(color_palette)
    color_id = 0
    color_palette.each do |palette|
      if palette.length == 3
        @palette[color_id]["r"] = palette[0].to_i
        @palette[color_id]["g"] = palette[1].to_i
        @palette[color_id]["b"] = palette[2].to_i
        color_id+=1
      end
    end
  end
end
