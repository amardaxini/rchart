require 'rubygems'
require "gd2_helper"
require "graph"
require "gd2-ffij"
class Rchart
  include   GD2
  include Graph
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
	FONT_PATH =  File.expand_path(File.join(File.dirname(__FILE__),"fonts"))
	attr_accessor :antialias_quality,:picture
	# This function create a new chart object.
	# This object will be used during all the steps of the graph creation.
	# This object will embed all the pChart functions
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
    
		@picture =  image_create_true_color(@x_size, @y_size)
		@c_white =  allocate_color(@picture,255,255,255)
		image_filled_rectangle(@picture, 0, 0, @x_size, @y_size, 255,255,255)
		#image_color_transparent(@picture, 255,255,255)
		set_font_properties("tahoma.ttf",8)
	end
end
