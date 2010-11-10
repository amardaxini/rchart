require 'rubygems'
require 'gd2-ffij'

module GD2
  def image_create_true_color(width,height)
    # Image::IndexedColor.new(width,height)
    Image::TrueColor.new(width,height)
  end

  def add_point(x,y)
    Canvas::Point.new(x,y)
  end

  def image_color_allocate(picture,r,g,b)
    Color.new(r,g,b) # returns an integer value
  end

  def image_ttf_text(picture,font_size,angle,x_pos,y_pos,fg_color,font_name,string,options={})
    angle = deg2rad(angle)
    font = Font::TrueType.new(font_name, font_size,options)
    point= add_point(x_pos,y_pos)
    text = Canvas::Text.new(font,point,angle,string)
    text.draw(picture,fg_color.rgba)
  end

  # color helper
  def image_ftb_box(font_size,angle,font_name,string,x=0,y=0,options={})
    angle = deg2rad(angle)
    font = Font::TrueType.new(font_name, font_size,options)
    position = font.bounding_rectangle(string,angle)
    [position[:lower_left][0],position[:lower_left][1],position[:lower_right][0],position[:lower_right][1],position[:upper_right][0],position[:upper_right][1],position[:upper_left][0],position[:upper_left][1]]
  end #Compute and draw the scale



  def image_set_pixel(picture,x,y,r,g,b)
    color= image_color_allocate(picture,r,g,b)
    picture.set_pixel(x,y,color.rgba.to_i)
  end

  def image_color_at(picture,x,y)
    pixel = picture.get_pixel(x, y)
    #	rgb_color(picture, pixel)
  end
  def image_line(picture,x1,y1,x2,y2,r,g,b)
    color = allocate_color(picture,r,g,b)
    point1 = add_point(x1,y1)
    point2 = add_point(x2,y2)
    line = Canvas::Line.new(point1,point2)
    line.draw(picture,color)
  end

  def image_filled_rectangle(picture,x1,y1,x2,y2,r,g,b)
    color =  allocate_color(picture, r, g, b)
    point1 = add_point(x1,y1)
    point2 = add_point(x2,y2)
    filled_rectangle = Canvas::FilledRectangle.new(point1,point2)
    filled_rectangle.draw(picture,color.rgba)
  end
  def image_copy_merge(src_pic,dest_pic, dst_x, dst_y, src_x, src_y, dst_w, dst_h, pct, gray = false)
    dest_pic.merge_from(src_pic, dst_x, dst_y, src_x, src_y, dst_w, dst_h,pct/100.0)
  end

  def image_copy(src_pic,dest_pic,dest_x, dest_y, self_x, self_y, width, height)
    dest_pic.copy_from(src_pic,dest_x, dest_y, self_x, self_y, width, height)
  end

  def image_color_transparent(im,r,g,b)
    color = allocate_color(im, r, g, b)
    # im.save_alpha =true
    im.transparent = color

  end

  def image_destroy(image)
    GD2FFI.gdImageDestroy(image.image_ptr)
  end

  def image_create_from_png(file_name)
    Image.import(file_name)
  end
  def image_create_from_jpeg(file_name)
    Image.import(file_name)
  end
  def image_create_from_gif(file_name)
    Image.import(file_name)
  end
  def get_image_size(image)
    [image.width,image.height]
  end

  def image_filled_polygon(picture,points,r,g,b,points_count=0)
    color =  allocate_color(picture,r,g,b)
    polygon_points = []
    i=0
    if points_count == 0
      num_points = (points.length+1)
    else
      num_points = points_count+points_count
    end
    while(i<=num_points)
      j =i
      polygon_points << Canvas::Point.new(points[j],points[j+1]) if(!points[j+1].nil?)
      i = i+2
    end
    polygon=Canvas::FilledPolygon.new(polygon_points)
    polygon.draw(picture,color.to_i)
  end

  def rgb_color(picture,pixel)
    color = picture.pixel2color(pixel)
    [color.r,color.g,color.b]
  end
  # render Graph as png format
  def render_png(file_name,level=9)
    print_errors(@error_interface) if ( @error_reporting )
    file = File.new(file_name,"wb")
    file.write @picture.png(level)
    file.close
  end

  def export_image(file_name,options={})
    @picture.export(file_name,options)
  end

#Outputs the image in PNG format as String object.
#This method will be especially useful when you want to transmit an image directly to an user(i.e, without first writing it to a file)

  def render_png_str(level=9,img=self.picture)
    img.png(level)
  end

  def render_jepeg_str(level=9,img=self.picture)
    img.png(level)
  end
  def render_gif_str(img=self.picture)
    img.gif
  end

  def render_wbmp_str(fgcolor,img=self.picture)
    img.wbmp(fgcolor)
  end

  def render_gd_str(img=self.picture)
    img.gd(fgcolor)
  end
  # Format flags for Image#gd2
  # GD2::FMT_RAW
  # GD2::FMT_COMPRESSED
  def gd2(fmt= GD2::FMT_RAW,img=self.picture)
    img.gd2(fmt)
  end

  # render Graph as jpeg format
  def render_jpeg(file_name,quality=0)
    print_errors(@error_interface) if ( @error_reporting )
    file = File.new(file_name,"wb")
    file.write @picture.jpeg(quality)
    file.close
  end
end
