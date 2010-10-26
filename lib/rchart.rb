require "GD"
require 'rdata'

class Rchart
	SCALE_NORMAL = 1
	SCALE_ADDALL = 2
	SCALE_START0 = 3
	SCALE_ADDALLSTART0 = 4
	PIE_PERCENTAGE =  1
	PIE_LABELS = 2
	PIE_NOLABEL = 3
	PIE_PERCENTAGE_LABEL =  4
	TARGET_GRAPHAREA = 1
	TARGET_BACKGROUND = 2
	ALIGN_TOP_LEFT = 1
	ALIGN_TOP_CENTER = 2
	ALIGN_TOP_RIGHT = 3
	ALIGN_LEFT = 4
	ALIGN_CENTER = 5
	ALIGN_RIGHT = 6
	ALIGN_BOTTOM_LEFT = 7
	ALIGN_BOTTOM_CENTER = 8
	ALIGN_BOTTOM_RIGHT = 9
	FONT_PATH = File.expand_path(File.join(File.dirname(__FILE__),"..","fonts"))
	attr_accessor :antialias_quality,:picture
	# This function create a new chart object.
	# This object will be used during all the steps of the graph creation.
	# This object will embed all the pChart functions.

	def initialize(x_size,y_size,options={})
		# Initialize variables
		# q    raise ArgumentError if (options[:x_size].nil? && options[:y_size].nil?)
		# Error management
		@error_reporting = false
		@error_interface = "cli"
		@errors         = []
		@error_font_name  = "#{FONT_PATH}/pf_arma_five.ttf"
		@error_font_size  = 6
		@x_size = x_size
		@antialias_quality=0
		@y_size = y_size
		@error_reporting = false
		@error_font_name =  "#{FONT_PATH}/pf_arma_five.ttf"
		@error_font_size = 6
		@currency = "Rs."
		@date_format = "%d/%m/%Y"
		@line_width = 1
		@line_dot_size = 0
		@anti_alias_quality = 0
		@shadow_active = false
		@shadow_x_distance = 1
		@shadow_y_distance = 1
		@shadow_r_color = 60
		@shadow_g_color = 60
		@shadow_b_color = 60
		@shadow_alpha = 50
		@shadow_blur = 0
		@tmp_dir = '/tmp'
		@font_size =8
		@font_name = "#{FONT_PATH}/tahoma.ttf"
		@divisions= 0

		@division_count = 0
		@division_height = 0
		@x_division_ratio =0
		@x_division_count = 0
		@x_division_height = 0
		@x_division_ratio = 0
		@palette = []
		@layers = []
		@g_area_x_offset =0
		@division_width = 0
		@vmin = nil
		@vmax = nil
		@v_x_min =nil
		@v_x_max=nil

		@x_divisions=0
		@data_count=nil
		@g_area_x1 = 0
		@g_area_y1 = 0
		@g_area_x2 = 0
		@g_area_y2 = 0
		@image_map = []
		# /* Image Map settings */
		@build_map=false
		@map_function      = nil
		@tmp_folder        = "tmp/"
		@map_id            = nil

		@palette =[{"r"=>188,"g"=>224,"b"=>46},
		           {"r"=>224,"g"=>100,"b"=>46},
		           {"r"=>224,"g"=>214,"b"=>46},
		           {"r"=>46,"g"=>151,"b"=>224},
		           {"r"=>176,"g"=>46,"b"=>224},
		           {"r"=>224,"g"=>46,"b"=>117},
		           {"r"=>92,"g"=>224,"b"=>46},
		           {"r"=>224,"g"=>176,"b"=>46}]
		@picture =  GD::Image.newTrueColor(@x_size, @y_size)
		@c_white =  @picture.colorAllocate(255,255,255)
		image_filled_rectangle(@picture, 0, 0, @x_size, @y_size, 255,255,255)
		#image_color_transparent(@picture, 255,255,255)
		self.set_font_properties("tahoma.ttf",8)
	end
	# Use this function to enable error reporting during the chart rendering.
	# By default messages are redirected to the console while using the render command and using GD while using the stroke command.
	# You can force the errors to be redirected to either cli or gd specifying it as parameter.
	def report_warnings(interface="cli")
		@error_reporting = true
		@error_interface = interface
	end

	# Set font Properties font_name,font_size
	# font_name is
	# * GeosansLight.ttf,
	# * MankSans.ttf,
	# * pf_arma_five.ttf,
	# * Silkscreen.ttf,
	# * tahoma.ttf
	def set_font_properties(font_name, font_size)
		@font_size = font_size
		@font_name = "#{FONT_PATH}/#{font_name}"
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

	def validate_color(b, g, r)
		r = 0    if ( r < 0 )
		r = 255  if ( r > 255 )
		g = 0    if ( g < 0 )
		g = 255  if ( g > 255 )
		b = 0    if ( b < 0 )
		b = 255  if ( b > 255 )
		return b, g, r
	end

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
	# This file must be formated with three values per line ( r,g,b ).
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
		self.draw_filled_rectangle(@g_area_x1,@g_area_y1,@g_area_x2,@g_area_y2,r,g,b,false)
		self.draw_rectangle(@g_area_x1,@g_area_y1,@g_area_x2,@g_area_y2,r-40,g-40,b-40)
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
			if(scale_mode == SCALE_NORMAL || scale_mode == SCALE_START0)
				@vmin = 0 if (scale_mode == SCALE_START0 )

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
			elsif ( scale_mode == SCALE_ADDALL || scale_mode == SCALE_ADDALLSTART0 ) # Experimental
				@vmin = 0 if (scale_mode == SCALE_ADDALLSTART0)
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
			data_range = 0.1 if (data_range == 0 )

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
					scale4 = ( @vmax - @vmin )*1.0 / factor / 4
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
		data_range = 0.1  if (data_range == 0 )
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
			data_range = 0.1 if (data_range == 0 )

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
				#	scale4 = ( @vmax - @vmin )*1.0 / factor / 4

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
		data_range = 0.1  if (data_range == 0 )
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
			data_range = 0.1 if (data_range.to_f == 0.0)

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
					grid_id     = floor( @v_x_min / scale / factor);
					@v_x_min = grid_id * scale * factor
					x_divisions+=1
				end
			else #/* Can occurs for small graphs */
				scale = 1;
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
		# Write the Y Axis caption if set
		if ((!data_description["axis"].nil? && !data_description["axis"]["y"].nil?) )
			position   = image_ftb_box(@font_size,90,@font_name,data_description["axis"]["y"])
		#	text_height  = (position[1]).abs+(position[3]).abs
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
			#c_white         = allocate_color(@layers[0],255,255,255);
			image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
			image_color_transparent(@layers[0],255,255,255)

			#c_rectangle =allocate_color(@layers[0],250,250,250);

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
			image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha);
			@layers[0].destroy
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


	# This function evaluate the width and height of the box generated by the draw_legend.
	# This will help you to calculate dynamicaly the position where you want to print it (eg top-right).
	# You must provide the data_description array as only parameter.
	# This function will return and array containing in the first row the width of the box and in the second row the height of the box.
	
	def get_legend_box_size(data_description)
		return(-1) if data_description["description"].nil?
		# <-10->[8]<-4->Text<-10-> 
		max_width = 0
		max_height = 8
		data_description["description"].each do |key,value|
			position   = image_ftb_box(@font_size,0,@font_name,value)
			text_width  = position[2]-position[0]
			text_height = position[1]-position[7]
			max_width = text_width if (text_width > max_width)
			max_height = max_height + text_height + 4
		end
		max_height = max_height - 3
		max_width  = max_width + 32

		[max_width,max_height]
	end
	# This function will draw the legend of the graph ( serie color & serie name ) at the specified position.
	# The r,g,bparameters are used to set the background color. You can optionally provide the shadow color using the rs,gs,bs parameters.
	# You can also customize the text color using the rt,gt,bt.
	# Setting Border to false remove the surrounding box.
	
	def draw_legend(x_pos,y_pos,data_description,r,g,b,rs=-1,gs=-1,bs=-1,rt=0,gt=0,bt=0,border=true)
		#Validate the Data and data_description array 
		data_description = self.validate_data_description("draw_legend",data_description)
		return(-1) if (data_description["description"].nil?)
		c_text_color = allocate_color(@picture, rt, gt, bt)
		# <-10->[8]<-4->Text<-10-> 
		max_width = 0
		max_height = 8
		data_description["description"].each do |key,value|
			position   = image_ftb_box(@font_size,0,@font_name,value)
			text_width  = position[2]-position[6].abs
			text_height = position[1]-position[7]
			max_width = text_width if ( text_width > max_width)
			max_height = max_height + text_height + 4
		end
		max_height = max_height - 5
		max_width  = max_width + 32
		if ( rs == -1 || gs == -1 || bs == -1 )
			rs = r-30
			gs = g-30
			bs = b-30
    end

		if ( border )
			
			self.draw_filled_rounded_rectangle(x_pos+1,y_pos+1,x_pos+max_width+1,y_pos+max_height+1,5,rs,gs,bs)
			self.draw_filled_rounded_rectangle(x_pos,y_pos,x_pos+max_width,y_pos+max_height,5,r,g,b)
		end
		y_offset = 4 + @font_size
		id = 0

		data_description["description"].each do |key,value|
			self.draw_filled_rounded_rectangle(x_pos+10,y_pos+y_offset-4 , x_pos+14, y_pos+y_offset-4, 2, @palette[id]["r"], @palette[id]["g"], @palette[id]["b"])
			image_ttf_text(@picture, @font_size,0, x_pos+22, y_pos+y_offset, c_text_color, @font_name, value)
			position   = image_ftb_box(@font_size,0,@font_name,value);
			text_height = position[1]-position[7]
			y_offset = y_offset + text_height + 4
			id=id+1
		end
	end

	# This function will draw the legend of a pie graph ( serie color & value name ).
	# Be carrefull, dataset used for pie chart are not the same than for other line / curve / plot graphs.
	# You can specify the position of the legend box and the background color.
	def draw_pie_legend(x_pos,y_pos,data,data_description,r,g,b)
		data_description = self.validate_data_description("draw_pie_legend",data_description,false)
		self.validate_data("draw_pie_legend",data)
		return(-1) if (data_description["position"].nil?)
		c_text_color = allocate_color(@picture,0,0,0)

		# <-10->[8]<-4->Text<-10-> */
		max_width = 0
		max_height = 8
		data.each do |key|
			value = key[data_description["position"]]
			position  = image_ftb_box(@font_size,0,@font_name,value)
			text_width = position[2]-position[0]
			text_height = position[1]-position[7]
			max_width = text_width if ( text_width > max_width)
			max_height = max_height + text_height + 4
		end
		max_height = max_height - 3
		max_width  = max_width + 32
		self.draw_filled_rounded_rectangle(x_pos+1,y_pos+1,x_pos+max_width+1,y_pos+max_height+1,5,r-30,g-30,b-30)
		self.draw_filled_rounded_rectangle(x_pos,y_pos,x_pos+max_width,y_pos+max_height,5,r,g,b)
		y_offset = 4 + @font_size
		id = 0
		data.each do |key|
			value     = key[data_description["position"]]
			position   = image_ftb_box(@font_size,0,@font_name,value);
			text_height = position[1]-position[7]
			self.draw_filled_rectangle(x_pos+10,y_pos+y_offset-6,x_pos+14,y_pos+y_offset-2,@palette[id]["r"],@palette[id]["g"],@palette[id]["b"]);
			image_ttf_text(@picture,@font_size,0,x_pos+22,y_pos+y_offset,c_text_color,@font_name,value)
			y_offset = y_offset + text_height + 4
			id= id+1
		end
	end

	# This function is used to write the graph title.
	# Used with default parameters you must specify the bottom left position of the text.
	# if you are specifying x2 and y2 the text will be centered horizontaly and verticaly in the box of coordinates (x1,y1)-(x2,y2).
	# value correspond to the text that will be written on the graph.
	# r, g and b are used to set the text color.
	# Setting shadow to true will makes a shadow behind the text.
	def draw_title(x_pos,y_pos,value,r,g,b,x_pos2=-1,y_pos2=-1,shadow=false)
		c_text_color =   allocate_color(@picture, r, g, b)
		if ( x_pos2 != -1 )
			position  = image_ftb_box(@font_size,0,@font_name,value)
			text_width = position[2]-position[0]
			x_pos      =(( x_pos2 - x_pos -text_width ) / 2 ).floor + x_pos
		end
		if ( y_pos2 != -1 )
			position   = image_ftb_box(@font_size,0,@font_name,value)
			text_height = position[5]-position[3]
			y_pos       =(( y_pos2 - y_pos - text_height ) / 2 ).floor + y_pos
		end
		if ( shadow )
			c_shadow_color = allocate_color(@picture,@shadow_r_color,@shadow_g_color,@shadow_b_color)
			image_ttf_text(@picture,@font_size,0,x_pos+@shadow_x_distance,y_pos+@shadow_y_distance, c_shadow_color ,@font_name,value)
		end
		image_ttf_text(@picture,@font_size,0,x_pos,y_pos,c_text_color,@font_name,value);
	end

	# Use this function to write text over the picture.
	# You must specify the coordinate of the box where the text will be written using the (x1,y1)-(x2,y2) parameters, the text angle and the text color with the r,g,b parameters.
	# You can choose how the text will be aligned with the align parameter :
	# * Rchart:: ALIGN_TOP_LEFT Use the box top left corner.
	# * Rchart:: ALIGN_TOP_CENTER Use the box top center corner.
	# * Rchart:: ALIGN_TOP_RIGHT Use the box top right corner.
	# * Rchart:: ALIGN_LEFT Use the center left.
	# * Rchart:: ALIGN_CENTER Use the center.
	# * Rchart:: ALIGN_RIGHT Use the center right.
	# * Rchart:: ALIGN_BOTTOM_LEFT Use the box bottom left corner.
	# * Rchart:: ALIGN_BOTTOM_CENTER Use the box bottom center corner.
	# * Rchart:: ALIGN_BOTTOM_RIGHT Use the box bottom right corner.

	def draw_text_box(x1,y1,x2,y2,text,angle=0,r=255,g=255,b=255,align=ALIGN_LEFT,shadow=true,bgr=-1,bgg=-1,bgb=-1,alpha=100)
		position   = image_ftb_box(@font_size,angle,@font_name,text)
		text_width  = position[2]-position[0]
		text_height = position[5]-position[3]
		area_width  = x2 - x1
		area_height = y2 - y1
		x =nil
		y = nil

		if ( bgr != -1 && bgg != -1 && bgb != -1 )
			self.draw_filled_rectangle(x1,y1,x2,y2,bgr,bgg,bgb,false,alpha)
		end

		if ( align == ALIGN_TOP_LEFT )
			x = x1+1
			y = y1+@font_size+1
		end

		if ( align == ALIGN_TOP_CENTER )
			x = x1+(area_width/2)-(text_width/2)
			y = y1+@font_size+1
		end

		if ( align == ALIGN_TOP_RIGHT )
			x = x2-text_width-1
			y = y1+@font_size+1
		end
		if ( align == ALIGN_LEFT )
			x = x1+1
			y = y1+(area_height/2)-(text_height/2)
		end
		if ( align == ALIGN_CENTER )
			x = x1+(area_width/2)-(text_width/2)
			y = y1+(area_height/2)-(text_height/2)
		end
		if ( align == ALIGN_RIGHT )
			x = x2-text_width-1
			y = y1+(area_height/2)-(text_height/2)
		end
		if ( align == ALIGN_BOTTOM_LEFT )
			x = x1+1
			y = y2-1
		end
		if ( align == ALIGN_BOTTOM_CENTER )
			x = x1+(area_width/2)-(text_width/2)
			y = y2-1
		end
		if ( align == ALIGN_BOTTOM_RIGHT )
			x = x2-text_width-1
			y = y2-1
		end
		c_text_color   =allocate_color(@picture,r,g,b)
		c_shadow_color =allocate_color(@picture,0,0,0)
		if ( shadow )
			image_ttf_text(@picture,@font_size,angle,x+1,y+1,c_shadow_color,@font_name,text)
		end

		image_ttf_text(@picture,@font_size,angle,x,y,c_text_color,@font_name,text)
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

	# This function will draw a label over the graph.
	# You must specify the data & data_description structures, the serie name ( "Serie1" by default if only one ),
	# the x position of the value in the data array (will be numeric starting at 0 if no abscise_label are defined or the value of the selected abscise serie if specified), the caption that will displayed and optionally the color of the label
	
	def set_label(data,data_description,serie_name,value_name,caption,r=210,g=210,b=210)
		data_description = self.validate_data_description("set_label",data_description)
		self.validate_data("set_label",data)
		shadow_factor = 100
		c_label   =allocate_color(@picture,r,g,b)
		c_shadow     =allocate_color(@picture,r-shadow_factor,g-shadow_factor,b-shadow_factor)
		c_text_color   =allocate_color(@picture,0,0,0)
		cp = 0
		found = false
		numerical_value = 0
		data.each do |key|
			if key[data_description["position"]].to_s == value_name.to_s
				numerical_value = key[serie_name]
				found = true
			end
			cp +=1 if !found
		end

		xpos = @g_area_x1 + @g_area_x_offset + ( @division_width * cp ) + 2
		ypos = @g_area_y2 - (numerical_value - @vmin) *@division_ratio
		position  = image_ftb_box(@font_size,0,@font_name,caption)
		text_height = position[3] - position[5]
		text_width  = position[2]-position[0] + 2
		text_offset = (text_height/2).floor
		# Shadow
		poly = [xpos+1,ypos+1,xpos + 9,ypos - text_offset,xpos + 8,ypos + text_offset + 2]
		image_filled_polygon(@picture,poly,r-shadow_factor,g-shadow_factor,b-shadow_factor,3)
		self.draw_line(xpos,ypos+1,xpos + 9,ypos - text_offset - 0.2,r-shadow_factor,g-shadow_factor,b-shadow_factor)
		self.draw_line(xpos,ypos+1,xpos + 9,ypos + text_offset + 2.2,r-shadow_factor,g-shadow_factor,b-shadow_factor)
		self.draw_filled_rectangle(xpos + 9,ypos - text_offset-0.2,xpos + 13 + text_width,ypos + text_offset + 2.2,r-shadow_factor,g-shadow_factor,b-shadow_factor)

		#Label background
		poly = [xpos,ypos,xpos + 8,ypos - text_offset - 1,xpos + 8,ypos + text_offset + 1]
		image_filled_polygon(@picture,poly,r,g,b,3)
		self.draw_line(xpos-1,ypos,xpos + 8,ypos - text_offset - 1.2,r,g,b)
		self.draw_line(xpos-1,ypos,xpos + 8,ypos + text_offset + 1.2,r,g,b)
		self.draw_filled_rectangle(xpos + 8,ypos - text_offset - 1.2,xpos + 12 + text_width,ypos + text_offset + 1.2,r,g,b)

		image_ttf_text(@picture,@font_size,0,xpos + 10,ypos + text_offset,c_text_color,@font_name,caption)
	end

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
			r = @palette[color_id]["r"];
			g = @palette[color_id]["g"];
			b = @palette[color_id]["b"];
			r2 = ro
			g2 = go
			b2 = bo
			#TODO convert this function

			if ( !data_description["symbol"].nil? && !data_description["symbol"][col_name].nil?)
				is_alpha = false # ((ord ( file_get_contents (data_description["symbol"][col_name], false, NULL, 25, 1)) & 6) & 4) == 4;
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
					#add_to_image_map(x_pos-h_size,y_pos-h_size,x_pos+1+h_size,y_pos+h_size+1,data_description["description"][col_name],key[col_name].data_description["unit"]["y"],"Plot");
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
								self.draw_filled_circle(x_pos+1,y_pos+1,small_radius,r2,g2,b2);
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
		r = @palette[palette_id]["r"];
		g = @palette[palette_id]["g"];
		b = @palette[palette_id]["b"];
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
						self.draw_filled_circle(x+2,y+2,big_radius,r3,g3,b3)
					end
				end
				self.draw_filled_circle(x+1,y+1,big_radius,r,g,b);

				if ( r2 !=-1 && g2 !=-1 && b2 !=-1 )
					self.draw_filled_circle(x+1,y+1,small_radius,r2,g2,b2)
				else
					r2 = @palette[palette_id]["r"]+20
					r = 255 if ( r > 255 )
					g2 = @palette[palette_id]["g"]+20
					g = 255 if ( g > 255 )
					b2 = @palette[palette_id]["b"]+20
					b = 255 if ( b > 255 )
					self.draw_filled_circle(x+1,y+1,small_radius,r2,g2,b2);
				end
			end
		end
	end

	#	This function will draw an area between two data series.
	# extracting the minimum and maximum value for each X positions.
	# You must specify the two series name and the area color.
	# You can specify the transparency which is set to 50% by default.

	def draw_area(data,serie1,serie2,r,g,b,alpha = 50)
		self.validate_data("draw_area",data)
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
		image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha);
		image_destroy(@layers[0])
	end

	# You can use this function to display the values contained in the series on top of the charts.
	# It is possible to specify one or multiple series to display using and array.
	def write_values(data,data_description,series)

		data_description = self.validate_data_description("write_values",data_description)
		self.validate_data("write_values",data)
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
							#self.add_to_image_map(x_pos-3,y_pos-3,x_pos+3,y_pos+3,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"Line");
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

	# This function will draw a scatter line graph.
	# You must specify the x and y series that will be used.
	# You can optionnaly set the color index in the current palette.
	def draw_xy_graph(data,data_description,y_serie_name,x_serie_name,palette_id=0)
		y_last = -1
		x_last = -1
		data.each do |key|
			if ( !key[y_serie_name].nil? && !key[x_serie_name].nil? )
				x= key[x_serie_name]
				y = key[y_serie_name]
				y = @g_area_y2 - ((y-@vmin) * @division_ratio);
				x=  @g_area_x1 + ((x-@v_x_min) * @x_division_ratio);
				if (x_last != -1 && y_last != -1)
					self.draw_line(x_last,y_last,x,y,@palette[palette_id]["r"],@palette[palette_id]["g"],@palette[palette_id]["b"],true)
				end
				x_last = x
				y_last = y
			end
		end
	end

	# This function will draw a curved line graph using all the registered series. 
	# This curve is using a cubic algorythm to process the average values between two points.
	# You have to specify the accuracy between two points, typicaly a 0.1 value is acceptable. the smaller the value is, the longer it will take to process the graph.
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
				y_pos = layer_height - ((value-@vmin) * @division_ratio);

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
					#  imagefilledpolygon(@layers[0],a_points,4,$C_Graph);
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

			image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha);
			image_destroy(@layers[0])

			self.	draw_cubic_curve(data, data_description,accuracy,col_name)
			graph_id+=1
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
					#self.add_to_image_map(xpos-3,ypos-3,xpos+3,ypos+3,data_description["description"][col_name],key[col_name].data_description["unit"]["Y"],"FLine");
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
				xlast = xpos;
				xpos  = xpos + @division_width
			end

			a_points << layer_width - @g_area_x_offset
			a_points << layer_height;

			if ( around_zero == false )
			#	c_graph = allocate_color(@layers[0],@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"])
				image_filled_polygon(@layers[0],a_points,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],points_count);
			end

			image_copy_merge(@layers[0],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha);
			image_destroy(@layers[0])
			graph_id+=1
			self.draw_line_graph(data,data_description,col_name)
		end

	end
	# This function will draw a bar graph using all the registered series.
	# When creating a bar graph, don't forget to set the with_margin parameter of the draw_scale function to true.
	# Setting shadow to true will draw a shadow behind each series, this will also slow down a bit the renderer engine.

	def draw_bar_graph(data,data_description,shadow=false,alpha=100)
		data_description = self.validate_data_description("drawBarGraph",data_description)
		self.validate_data("drawBarGraph",data)

		graph_id      = 0
		series       = (data_description["values"]).count
		series_width  = @division_width / (series+1)
		serie_x_offset = @division_width / 2 - series_width / 2

		y_zero  = @g_area_y2 - ((0-@vmin) * @division_ratio)
		y_zero = @g_area_y2 if ( y_zero> @g_area_y2 )
		serie_id = 0
		color_id =0
		id = 0
		data_description["values"].each do |col_name|
			data_description["description"].each do |key_i,value_i|
				if ( key_i == col_name )
					color_id = id
					id = id+1
				end
			end
			x_pos = @g_area_x1 + @g_area_x_offset - serie_x_offset + series_width * serie_id
			x_last = -1
			data.each do |key|
				if ( !key[col_name].nil?)
					if ( key[col_name].is_a?(Numeric) )
						value = key[col_name]
						y_pos = @g_area_y2 - ((value-@vmin) * @division_ratio)
						#  Save point into the image map if option activated */
						if (@build_map )
							#self.add_to_image_map(x_pos+1,[y_zero,y_pos].min,x_pos+series_width-1,[y_zero,y_pos].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"Bar");
						end
						if ( shadow && alpha == 100 )
							self.draw_rectangle(x_pos+1,y_zero,x_pos+series_width-1,y_pos,25,25,25)
						end
						self.draw_filled_rectangle(x_pos+1,y_zero,x_pos+series_width-1,y_pos,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true,alpha)
					end
					x_pos = x_pos + @division_width
				end
			end
			serie_id = serie_id+1
		end
	end

	# This function will draw a stacked bar graph using all the registered series.
	# When creating a bar graph, don't forget to set the with_margin parameter of the draw_scale function to true.
	# Don't forget to change the automatic scaling to Rchart::SCALE_ADDALL to have an accurate scaling mode.
	# You can specify the transparency and if the bars must be contiguous or with space (default) 
	def draw_stacked_bar_graph(data,data_description,alpha=50,contiguous=false)
		# /* Validate the Data and data_description array */
		data_description = self.validate_data_description("draw_bar_graph",data_description)
		self.validate_data("draw_bar_graph",data)
		graph_id      = 0
		series       = (data_description["values"].count)
		if ( contiguous )
			series_width  = @division_width
		else
			series_width  = @division_width * 0.8;
		end
		y_zero  = @g_area_y2 - ((0-@vmin) * @division_ratio)
		y_zero = @g_area_y2 if ( y_zero > @g_area_y2 )
		series_id = 0
		last_value = {}
		id = 0
		color_id = 0
		data_description["values"].each do |col_name|
			data_description["description"].each do |key_i,value_i|
				if ( key_i == col_name )
					color_id = id
					id = id+1
				end
			end
			x_pos  = @g_area_x1 + @g_area_x_offset - series_width / 2
			x_last = -1
			data.each do |key|
				if ( !key[col_name].nil?)
					if ( key[col_name].is_a?(Numeric) )
						value = key[col_name]
						if (!last_value[key].nil?)
							y_pos    = @g_area_y2 - (((value+last_value[key])-@vmin) * @division_ratio)
							y_bottom = @g_area_y2 - ((last_value[key]-@vmin) * @division_ratio)
							last_value[key] += value
						else
							y_pos    = @g_area_y2 - ((value-@vmin) * @division_ratio)
							y_bottom = y_zero
							last_value[key] = value
						end
						# Save point into the image map if option activated 
						if ( @build_map )
							#self.add_to_image_map(x_pos+1,[y_bottom,y_pos].min,x_pos+series_width-1,[y_bottom,y_pos].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"sBar");
						end
						self.draw_filled_rectangle(x_pos+1,y_bottom,x_pos+series_width-1,y_pos,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true,alpha)
					end
				end
				x_pos = x_pos + @division_width
			end
			series_id+=1
		end
	end
	# This function will draw a superposed bar graph using all the registered series. 
	# You can provide the alpha value used when merging all series layers.
	
	def draw_overlay_bar_graph(data,data_description,alpha=50)
		data_description = self.validate_data_description("draw_overlay_bar_graph",data_description)
		self.validate_data("draw_overlay_bar_graph",data)
		layer_width  = @g_area_x2-@g_area_x1
		layer_height = @g_area_y2-@g_area_y1
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
			@layers[graph_id] = image_create_true_color(layer_width,layer_height)
			image_filled_rectangle(@layers[graph_id],0,0,layer_width,layer_height,255,255,255)
			image_color_transparent(@layers[graph_id],255,255,255)
			x_width = @division_width / 4
			x_pos   = @g_area_x_offset
			y_zero  = layer_height - ((0-@vmin) * @division_ratio)
			x_last  = -1
			points_count = 2
			data.each do |key|
				if(!key[col_name].nil?)
					if(key[col_name].is_a?(Numeric))
						value = key[col_name]
						if (value.is_a?(Numeric) )
							y_pos  = layer_height - ((value-@vmin) * @division_ratio)
							image_filled_rectangle(@layers[graph_id],x_pos-x_width,y_pos,x_pos+x_width,y_zero,@palette[graph_id]["r"],@palette[graph_id]["g"],@palette[graph_id]["b"])
							x1 = (x_pos - x_width + @g_area_x1).floor
							y1 = (y_pos+@g_area_y1).floor + 0.2
							x2 = (x_pos + x_width + @g_area_x1).floor
							y2 = @g_area_y2 - ((0-@vmin) * @division_ratio)
							x1 = @g_area_x1 + 1 if ( x1 <= @g_area_x1 )
							x2 = @g_area_x2 - 1 if ( x2 >= @g_area_x2 )

							# Save point into the image map if option activated */
							if ( @build_map )
								#self.add_to_image_map(x1,[y1,y2].min,x2,[y1,y2].max,data_description["description"][col_name],data[key][col_name].data_description["unit"]["y"],"oBar");
							end
							self.draw_line(x1,y1,x2,y1,@palette[color_id]["r"],@palette[color_id]["g"],@palette[color_id]["b"],true)
						end
					end
				end
				x_pos = x_pos + @division_width
			end
			graph_id+=1
		end
		i=0
		while (i<=(graph_id-1))
			image_copy_merge(@layers[i],@picture,@g_area_x1,@g_area_y1,0,0,layer_width,layer_height,alpha)
			image_destroy(@layers[i])
			i=i+1
		end
	end

	# This function will draw the minimum & maximum values for a specific point using all the registered series
	# You can optionaly specify the vertical line color.

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
			self.draw_line(xpos.floor-0.2,y1+1,xpos.floor-0.2,y2-1,r,g,b,true)
			self.draw_line(xpos.floor+0.2,y1+1,xpos.floor+0.2,y2-1,r,g,b,true)
			self.draw_line(x1,y1,x2,y1,@palette[max_id]["r"],@palette[max_id]["g"],@palette[max_id]["b"],false)
			self.draw_line(x1,y2,x2,y2,@palette[min_id]["r"],@palette[min_id]["g"],@palette[min_id]["b"],false)
			xpos = xpos + @division_width
		end
	end

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
	def draw_basic_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=PIE_NOLABEL,r=255,g=255,b=255,decimals=0)
		data_description = self.validate_data_description("draw_basic_pie_graph",data_description,false)
		self.validate_data("drawBasicPieGraph",data)
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
			raise_fatal("Pie chart can only accept one serie of data.");
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
			caption = "";
			if ( !(draw_labels == PIE_NOLABEL) )
				t_angle  = angle+(value*splice_ratio/2)
				if (draw_labels == PIE_PERCENTAGE)
					caption  = ((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
				elsif (draw_labels == PIE_LABELS)
					caption  = i_labels[key]
				elsif (draw_labels == PIE_PERCENTAGE_LABEL)
					caption  = i_labels[key].to_s+"\r\n"+"."+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%";
				elsif (draw_labels == PIE_PERCENTAGE_LABEL)
					caption  = i_labels[key].to_s+"\r\n"+"."+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%";
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

				c_text_color = allocate_color(@picture,70,70,70);
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
		self.draw_circle(x_pos-0.5,y_pos-0.5,radius,r,g,b)
		self.draw_circle(x_pos-0.5,y_pos-0.5,radius+0.5,r,g,b)
		# Draw Top polygons 
		top_plots.each_with_index do  |value,key|
			j = 0
			while(j<=top_plots[key].count-4 )
				self.draw_line(top_plots[key][j],top_plots[key][j+1],top_plots[key][j+2],top_plots[key][j+3],r,g,b);
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
	def draw_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=PIE_NOLABEL,enhance_colors=true,skew=60,splice_height=20,splice_distance=0,decimals=0)
		data_description = self.validate_data_description("draw_pie_graph",data_description,false)
		self.validate_data("draw_pie_graph",data)

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

		#RaiseFatal("Pie chart can only accept one serie of data.");
		#puts "Error Pie chart can only accept one serie of data." if ( series != 1 )
		splice_distance_ratio = splice_distance
		skew_height          = (radius * skew) / 100;
		splice_ratio         = ((360 - splice_distance_ratio *i_values.count*1.0)  / pie_sum)
		splice_percent       = 100.0 / pie_sum
		r_splice_percent      = 100.0 / rpie_sum
		#Calculate all polygons
		angle    = 0
		c_dev = 5;
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
			if ( !(draw_labels == PIE_NOLABEL) )

				t_angle   = angle+(value*splice_ratio/2)
				if (draw_labels == PIE_PERCENTAGE)
					caption  = ((r_values[key] * (10**decimals) * r_splice_percent)/(10**decimals)).round.to_s+"%"
				elsif (draw_labels == PIE_LABELS)
					caption  = i_labels[key]
				elsif (draw_labels == PIE_PERCENTAGE_LABEL)
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
				#c_text_color = $this->AllocateColor(@picture,70,70,70);
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
			#c_graph_lo = allocate_color(@picture,@palette[key]["r"]-20,@palette[key]["g"]-20,@palette[key]["b"]-20)
			image_filled_polygon(@picture,bot_plots[key],@palette[key]["r"]-20,@palette[key]["g"]-20,@palette[key]["b"]-20)
			if (enhance_colors)
				en = -10
			else
				en = 0
			end
			j =0
			while(j<=(abot_plots[key].length)-4)
				self.draw_line(abot_plots[key][j],abot_plots[key][j+1],abot_plots[key][j+2],abot_plots[key][j+3],@palette[key]["r"]+en,@palette[key]["g"]+en,@palette[key]["b"]+en);
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
			#	c_graph_lo = allocate_color(@picture,@palette[key]["r"]-10,@palette[key]["g"]-10,@palette[key]["b"]-10)
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

				self.draw_antialias_pixel(plots[0],plots[1],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor);
				self.draw_antialias_pixel(plots[2],plots[3],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor);
				self.draw_antialias_pixel(plots[index-4],plots[index-3],@palette[key]["r"]+color_factor,@palette[key]["g"]+color_factor,@palette[key]["b"]+color_factor);
			end
			i = i-1
		end
		#Draw Top polygons
		key = i_values.length-1
		while(key>=0)
		#	c_graph_lo = allocate_color(@picture,@palette[key]["r"],@palette[key]["g"],@palette[key]["b"])
			image_filled_polygon(@picture,top_plots[key],@palette[key]["r"],@palette[key]["g"],@palette[key]["b"])

			if ( enhance_colors )
				en = 10
			else
				en = 0
			end
			j = 0

			while(j<=(atop_plots[key]).length-4)
				self.draw_line(atop_plots[key][j],atop_plots[key][j+1],atop_plots[key][j+2],atop_plots[key][j+3],@palette[key]["r"]+en,@palette[key]["g"]+en,@palette[key]["b"]+en);
				j = j+2
			end
			key = key -1
		end
	end
	# This function is an alias of the draw_flat_pie_graph function.
	def draw_flat_pie_graph_with_shadow(data,data_description,x_pos,y_pos,radius=100,draw_labels=PIE_NOLABEL,splice_distance=0,decimals=0)
		self.draw_flat_pie_graph(data,data_description,x_pos+@shadow_x_distance,y_pos+@shadow_y_distance,radius,PIE_NOLABEL,splice_distance,decimals,true)
		self.draw_flat_pie_graph(data,data_description,x_pos,y_pos,radius,draw_labels,splice_distance,decimals,false)
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
	# * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150);
	# This will draw a pie graph centered at (150-150) with a radius of 50 and percentages
	# * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,50,Rchart::PIE_PERCENTAGE)
	# This will draw a pie graph centered at (150-150) with a radius of 100, captions and slightly exploded
	# * chart.draw_flat_pie_graph(chart_data.get_data,chart_data.get_data_description,150,150,100,Rchart::PIE_PERCENTAGE,4)

	def draw_flat_pie_graph(data,data_description,x_pos,y_pos,radius=100,draw_labels=PIE_NOLABEL,splice_distance=0,decimals=0,all_black=false)
		data_description = self.validate_data_description("draw_flat_pie_graph",data_description,false)
		self.validate_data("draw_flat_pie_graph",data)
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
			raise_fatal("Pie chart can only accept one serie of data.");
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
			if ( !(draw_labels == PIE_NOLABEL) )
				t_angle   = angle+(value*splice_ratio/2)
				if (draw_labels == PIE_PERCENTAGE)
					caption  = ((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
				elsif (draw_labels == PIE_LABELS)
					caption  = i_labels[key]
				elsif (draw_labels == PIE_PERCENTAGE_LABEL)
					caption  = i_labels[key].to_s+".\r\n"+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
				elsif (draw_labels == PIE_PERCENTAGE_LABEL)
					caption  = i_labels[key].to_s+".\r\n"+((value * (10**decimals) * splice_percent)/(10**decimals)).round.to_s+"%"
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
					self.draw_line(x_pos+x_offset,y_pos+y_offset,pos_x,pos_y,rc,gc,bc)
				end
				if ( x_line_last != "" )
					self.draw_line(x_line_last,y_line_last,pos_x,pos_y,rc,gc,bc);
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
	def draw_graph_area_gradient(r,g,b,decay,target=TARGET_GRAPHAREA)
		b, g, r = validate_color(b, g, r)
		x1,y1,x2,y2 = 0,0,0,0
		if ( target == TARGET_GRAPHAREA )
			x1 = @g_area_x1+1
			x2 = @g_area_x2-1
			y1 = @g_area_y1+1
			y2 = @g_area_y2
		end

		if ( target == TARGET_BACKGROUND )
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
				yi1 = y1 + ( i * y_step );
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
		self.draw_line(x1,y1,x2,y1,r,g,b)
		self.draw_line(x2,y1,x2,y2,r,g,b)
		self.draw_line(x2,y2,x1,y2,r,g,b)
		self.draw_line(x1,y2,x1,y1,r,g,b)
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
				self.draw_filled_rectangle(x1+@shadow_x_distance,y1+@shadow_y_distance,x2+@shadow_x_distance,y2+@shadow_y_distance,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha,true)
				if(@shadow_blur != 0)
					alpha_decay = (@shadow_alpha/ @shadow_blur)
					i =1
					while i<=@shadow_blur
						self.draw_filled_rectangle(x1+@shadow_x_distance-i/2,y1+@shadow_y_distance-i/2,x2+@shadow_x_distance-i/2,y2+@shadow_y_distance-i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha-alpha_decay*i,true)
						i = i+1
					end
					i = 1
					while i<=@shadow_blur
						self.draw_filled_rectangle(x1+@shadow_x_distance+i/2,y1+@shadow_y_distance+i/2,x2+@shadow_x_distance+i/2,y2+@shadow_y_distance+i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,false,@shadow_alpha-alpha_decay*i,true)
						i = i+1
					end
				end
			end
			image_filled_rectangle(@picture,x1.to_f.round,y1.to_f.round,x2.to_f.round,y2.to_f.round,r,g,b)
		else
			layer_width  = (x2-x1).abs+2
			layer_height = (y2-y1).abs+2
			@layers[0] = GD::Image.newTrueColor(layer_width,layer_height)
			c_white  = @layers[0].colorAllocate(255,255,255)
			image_filled_rectangle(@layers[0],0,0,layer_width,layer_height,255,255,255)
			@layers[0].transparent(c_white)
			image_filled_rectangle(@layers[0],1.round,1.round,(layer_width-1).round,(layer_height-1).round,r,g,b)
			image_copy_merge(@layers[0],@picture,([x1,x2].min-1).round,([y1,y2].min-1).round,0,0,layer_width,layer_height,alpha)
			#TODO Find out equivalent method
			@layers[0].destroy
		end
		if (draw_border )
			shadow_settings = @shadow_active
			@shadow_active = false
			self.draw_rectangle(x1,y1,x2,y2,r,g,b)
			@shadow_active = shadow_settings
		end
	end

	# This function draw an aliased rectangle with rounded corners
	# The upper left and bottom right border positions are used as first 4 arguments.
	# Argument #5 represents the radius of the rounded corner.
	# The last 3 parameters are used to set the border color.
	def draw_rounded_rectangle(x1, y1, x2, y2, radius,r, g, b)
		b, g, r = validate_color(b, g, r)

		#c_rectangle = allocate_color(@picture,r,g,b)

		step = 90 / ((3.1418 * radius)/2)
		i=0
		while i<=90
			x = Math.cos((i+180)*3.1418/180) * radius + x1 + radius
			y = Math.sin((i+180)*3.1418/180) * radius + y1 + radius
			self.draw_antialias_pixel(x,y,r,g,b)

			x = Math.cos((i-90)*3.1418/180) * radius + x2 - radius
			y = Math.sin((i-90)*3.1418/180) * radius + y1 + radius
			self.draw_antialias_pixel(x,y,r,g,b)

			x = Math.cos((i)*3.1418/180) * radius + x2 - radius
			y = Math.sin((i)*3.1418/180) * radius + y2 - radius
			self.draw_antialias_pixel(x,y,r,g,b)

			x = Math.cos((i+90)*3.1418/180) * radius + x1 + radius
			y = Math.sin((i+90)*3.1418/180) * radius + y2 - radius
			self.draw_antialias_pixel(x,y,r,g,b)
			i=i+step
		end

		x1=x1-0.2
		y1=y1-0.2
		x2=x2+0.2
		y2=y2+0.2
		self.draw_line(x1+radius,y1,x2-radius,y1,r,g,b)
		self.draw_line(x2,y1+radius,x2,y2-radius,r,g,b)
		self.draw_line(x2-radius,y2,x1+radius,y2,r,g,b)
		self.draw_line(x1,y2-radius,x1,y1+radius,r,g,b)
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

			self.draw_antialias_pixel(xi1,yi1,r,g,b)
			self.draw_antialias_pixel(xi2,yi2,r,g,b)
			self.draw_antialias_pixel(xi3,yi3,r,g,b)
			self.draw_antialias_pixel(xi4,yi4,r,g,b)
           
			i=i+step
        end

		image_filled_rectangle(@picture,x1,y1+radius,x2,y2-radius,r,g,b)

		image_filled_rectangle(@picture,x1+radius,y1,x2-radius,y2,r,g,b)

		x1=x1-0.2
		y1=y1-0.2
		x2=x2+0.2
		y2=y2+0.2
		self.draw_line(x1+radius,y1,x2-radius,y1,r,g,b)
		self.draw_line(x2,y1+radius,x2,y2-radius,r,g,b)
		self.draw_line(x2-radius,y2,x1+radius,y2,r,g,b)
		self.draw_line(x1,y2-radius,x1,y1+radius,r,g,b)
	end
	# This function draw an aliased circle at position (xc,yc) with the specified radius.
	# The last 3 parameters are used to set the border color.
	# Width is used to draw ellipses.
	def draw_circle(xc,yc,height,r,g,b,width=0)
		width = height if ( width == 0 )
		b, g, r = validate_color(b, g, r)
		step     = 360 / (2 * 3.1418 * [width,height].max)
		i =0
		while(i<=360)
			x= Math.cos(i*3.1418/180) * height + xc
			y = Math.sin(i*3.1418/180) * width + yc
			self.draw_antialias_pixel(x,y,r,g,b)
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
			self.draw_antialias_pixel(x1-1,y1-1,r,g,b)
			self.draw_antialias_pixel(x2-1,y2-1,r,g,b)
			image_line(@picture,x1,y1-1,x2-1,y2-1,r,g,b) if ( (y1-1) > yc - [width,height].max )
			i= i+step
		end
	end

	# This function draw an aliased ellipse at position (xc,yc) with the specified height and width. 
	# The last 3 parameters are used to set the border color.
	def draw_ellipse(xc,yc,height,width,r,g,b)
		self.draw_circle(xc,yc,height,r,g,b,width)
	end


	# This function draw a filled aliased ellipse at position (xc,yc) with the specified height and width.
	# The last 3 parameters are used to set the border and filling color. 
	def draw_filled_ellipse(xc,yc,height,width,r,g,b)
		self.draw_filled_circle(xc,yc,height,r,g,b,width)
	end

	# This function will draw an aliased line between points (x1,y1) and (x2,y2).
	# The last 3 parameters are used to set the line color.
	# The last optional parameter is used for internal calls made by graphing function.If set to true, only portions of line inside the graph area will be drawn.

	def draw_line(x1,y1,x2,y2,r,g,b,graph_function=false)
		if ( @line_dot_size > 1 )
			self.draw_dotted_line(x1,y1,x2,y2,@line_dot_size,r,g,b,graph_function)
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
							self.draw_antialias_pixel(x,y,r,g,b)
						else
							start_offset = -(@line_width/2)
							end_offset = (@line_width/2)
							j = start_offset

							while j<=end_offset
								self.draw_antialias_pixel(x+j,y+j,r,g,b)
								j+=1
							end
						end
					end
					i =i+1
				end
			end
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
						self.draw_antialias_pixel(x,y,r,g,b)
					else
						start_offset = start_offset -(@line_width/2)
						end_offset = (@line_width/2)
						j = start_offset
						while(j<= end_offset)
							self.draw_antialias_pixel(x+j,y+j,r,g,b)
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

# This function allows you to merge an external PNG picture with your graph specifying the position and the transparency
	def draw_from_png(file_name,x,y,alpha=100)
		self.draw_from_picture(1,file_name,x,y,alpha)
	end

	#This function allows you to merge an external GIF picture with your graph specifying the position and the transparenc
	#def draw_from_gif(file_name,x,y,alpha=100)
	#self.draw_from_picture(2,file_name,x,y,alpha)
	#end

	# This function allows you to merge an external JPG picture with your graph specifying the position and the transparency. 
	def draw_from_jpg(file_name,x,y,alpha=100)
		self.draw_from_picture(3,file_name,x,y,alpha)
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
	# color helper 
	def allocate_color(picture,r,g,b,factor=0)
		r = r + factor
		g = g + factor
		b = b + factor
		r = 0    if ( r < 0 )
		r = 255  if ( r > 255 )
		g = 0    if ( g < 0 )
		g = 255  if ( g > 255 )
		b = 0    if ( b < 0 )
		b = 255  if ( b > 255 )
		image_color_allocate(picture,r,g,b)
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

	# Private functions for internal processing Internal function.
	def draw_antialias_pixel(x,y,r,g,b,alpha=100,no_fall_back=false)
		#Process shadows
		if(@shadow_active && !no_fall_back)
			self.draw_antialias_pixel(x+@shadow_x_distance,y+@shadow_y_distance,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha,true)
			if(@shadow_blur != 0)
				alpha_decay = (@shadow_alpha*1.0 / @shadow_blur)
				i=1
				while i<=@shadow_blur
					self.draw_antialias_pixel(x+@shadow_x_distance-i/2,y+@shadow_y_distance-i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha-alpha_decay*i,true)
					i = i+1
				end
				i =1
				while i<=@shadow_blur
					self.draw_antialias_pixel(x+@shadow_x_distance+i/2,y+@shadow_y_distance+i/2,@shadow_r_color,@shadow_g_color,@shadow_b_color,@shadow_alpha-alpha_decay*i,true)
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
				self.draw_alpha_pixel(x,y,alpha,r,g,b)
			end
		else
			if xi > 0 || yi > 0 #soe error occures therefor added condtion
				alpha1 = (((1 - (x - x.floor)) * (1 - (y - y.floor)) * 100) / 100) * alpha
				self.draw_alpha_pixel(xi,yi,alpha1,r,g,b) if alpha1 > @anti_alias_quality
				alpha2 = (((x -  x.floor) * (1 - (y - y.floor)) * 100) / 100) * alpha
				self.draw_alpha_pixel(xi+1,yi,alpha2,r,g,b) if alpha2 > @anti_alias_quality
				alpha3 = (((1 - (x -  x.floor)) * (y - y.floor) * 100) / 100) * alpha
				self.draw_alpha_pixel(xi,yi+1,alpha3,r,g,b) if alpha3 > @anti_alias_quality
				alpha4 = (((x -  x.floor) * (y - y.floor) * 100) / 100) * alpha
				self.draw_alpha_pixel(xi+1,yi+1,alpha4,r,g,b)  if alpha4 > @anti_alias_quality
			end
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
		return(o)
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

		result_string = @currency.result_strin
		return(result_string)
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
			self.set_line_style(width=1)
			max_width = 0
			@errors.each do |value|
				position  = image_ftb_box(@error_font_size,0,@error_font_name,value)
				text_width = position[2]-position[0]
				max_width = text_width if ( text_width > max_width )
			end
			self.draw_filled_rounded_rectangle(@x_size-(max_width+20),@y_size-(20+((@error_font_size+4)*(@errors.count))),@x_size-10,@y_size-10,6,233,185,185)
			self.draw_rounded_rectangle(@x_size-(max_width+20),@y_size-(20+((@error_font_size+4)*(@errors.count))),@x_size-10,@y_size-10,6,193,145,145)
			c_text_color = allocate_color(@picture,133,85,85)
			ypos        = @y_size - (18 + ((@errors.count)-1) * (@error_font_size + 4))
			@errors.each do |value|
				image_ttf_text(@picture,@error_font_size,0,@x_size-(max_width+15),ypos,c_text_color,@error_font_name,value)
				ypos = ypos + (@error_font_size + 4)
			end
		end
	end
	# render Graph as png format
	def render_png(file_name)
		self.print_errors(@error_interface) if ( @error_reporting )
		file = File.new(file_name,"wb")
		@picture.png(file)
		file.close
	end
	# render Graph as jpeg format
	def render_jpeg(file_name,quality=0)
		self.print_errors(@error_interface) if ( @error_reporting )
		file = File.new(file_name,"wb")
		@picture.jpeg(file,quality)
		file.close
    end

#Outputs the image in PNG format as String object.
#This method will be especially useful when you want to transmit an image directly to an user(i.e, without first writing it to a file)

  def render_png_str(img=self.picture)
    img.pngStr
  end

  
  # resize image on passing png,jpeg,or gd image
	# pass file_name/gd image,new_file_name,percentage,or resize width,resize height
	def resize_image(file_name,resize_file_name="test",percentage=0,resized_width=0,resized_height=0)
		image = GD::Image.new_from_png(file_name) rescue ""
		render_file_as = "png"
		if !image.is_a?(GD::Image)
			image = GD::Image.new_from_jpeg(file_name) rescue ""
			render_file_as = "jpeg"
		elsif !image.is_a?(GD::Image)
			image = GD::Image.new_from_gd(file_name) rescue ""
			render_file_as = "png"
		end

		if image.is_a?(GD::Image)
			width=image.width
			height=image.height
			if percentage >0
				resized_width = (width*percentage)/100.0
				resized_height = (height*percentage)/100.0
			elsif(resized_width != 0 && resized_height ==0)

				resized_height = (100 /(width*1.0/resized_width) ) * 0.01
				resized_height = (height * resized_height).round
			elsif( resized_height != 0 && resized_width ==0)

				resized_width = (100 /(height*1.0/resized_height) ) * 0.01
				resized_width = (width * resized_width).round
			else
				resized_width = 100
				resized_height = 100
			end

			resize_image = GD::Image.newTrueColor(resized_width, resized_height)
			image.copyResized(resize_image, 0,0,0,0, resized_width,resized_height, width, height)
			file=File.new(resize_file_name,"wb")
			if render_file_as == "png"
				resize_image.png(file)
			elsif render_file_as == "jpeg"
				resize_image.jpeg(file)
			end
			file.close
		else
			puts "Provide proper image"
		end
	end
##########################################3
	#GD MAP FUNCTION HELPER
	#ON NEXT VERSION TRY TO MAP THIS FUNCTION WITH GD2 Gem
	def image_ttf_text(picture,font_size,angle,x_pos,y_pos,fg_color,font_name,str)
		angle = deg2rad(angle)
		err,brect=picture.stringTTF(fg_color, font_name, font_size, angle, x_pos, y_pos, str.to_s)
	end

	def image_ftb_box(font_size,angle,font_name,str,x=0,y=0)
		angle = deg2rad(angle)
		err,brect = GD::Image.stringFT(0, font_name, font_size, angle, x, y, str)
		brect
	end #Compute and draw the scale

	def image_color_allocate(picture,r,g,b)
		picture.colorAllocate(r,g,b)
	end

	def image_set_pixel(picture,x,y,r,g,b)
		color=image_color_allocate(picture,r,g,b)
		picture.setPixel(x,y,color)
	end

	def image_color_at(picture,x,y)
		color = picture.getPixel(x, y)
	end

	def image_line(picture,x1,y1,x2,y2,r,g,b)
		picture.line(x1, y1, x2, y2, allocate_color(picture,r,g,b))
	end

	def image_filled_rectangle(picture,x1,y1,x2,y2,r,g,b)
		color =  picture.colorAllocate(r,g,b)
		picture.filledRectangle(x1, y1, x2, y2, color)
	end

	def image_create_true_color(width,height)
		GD::Image.newTrueColor(width, height)
	end

	def image_copy_merge(src_pic,dest_pic, dst_x, dst_y, src_x, src_y, w, h, pct, gray = false)
		src_pic.copyMerge(dest_pic, dst_x, dst_y, src_x, src_y, w, h, pct)
	end

	def image_copy(src_pic,dst_pic,dest_x, dest_y, self_x, self_y, width, height)
		src_pic.copy(dst_pic,dest_x, dest_y, self_x, self_y, width, height)
	end

	def image_color_transparent(im,r,g,b)
		color=allocate_color(im, r, g, b)
		im.transparent(color)
	end

	def image_destroy(image)
		image.destroy
	end

	def image_create_from_png(file_name)
		GD::Image.new_from_png(file_name)
	end
	def image_create_from_jpeg(file_name)
		GD::Image.new_from_jpeg(file_name)
	end

	def get_image_size(image)
		[image.width,image.height]
	end

	def image_filled_polygon(picture,points,r,g,b,points_count=0)
		color =  allocate_color(picture,r,g,b)
		polygon=GD::Polygon.new
		i=0
		if points_count == 0
			num_points = (points.length+1)
		else
			num_points = points_count+points_count
		end
		while(i<=num_points)
			j =i
			polygon.addPt(points[j],points[j+1]) if(!points[j+1].nil?)
			i = i+2
		end
		picture.filledPolygon(polygon, color)
	end

end


