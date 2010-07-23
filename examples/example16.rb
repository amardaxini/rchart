# Playing with background

require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([9,9,9,10,10,11,12,14,16,17,18,18,19,19,18,15,12,10,9],"Serie1")
p.add_point([10,11,11,12,12,13,14,15,17,19,22,24,23,23,22,20,18,16,14],"Serie2")
p.add_point([4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22],"Serie3")
p.add_all_series
p.remove_serie("Serie3")
p.set_abscise_label_serie("Serie3")
p.set_serie_name("January","Serie1")
p.set_serie_name("February","Serie2")
p.set_y_axis_name("Temperature")
p.set_y_axis_unit("°C")
p.set_x_axis_unit("h")

ch = Rchart.new(700,230)
ch.draw_graph_area_gradient(132,153,172,50,Rchart::TARGET_BACKGROUND)
ch.set_font_properties("tahoma.ttf",8)
ch.set_graph_area(60,20,585,180)
ch.draw_graph_area(213,217,221,false)
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,213,217,221,true,0,2)
ch.draw_graph_area_gradient(162,183,202,50)
ch.draw_grid(4,true,230,230,230,20)

 # Draw the line chart
ch.set_shadow_properties(3,3,0,0,0,30,4)
ch.draw_line_graph(p.get_data,p.get_data_description)
ch.clear_shadow
ch.draw_plot_graph(p.get_data,p.get_data_description,4,2,-1,-1,-1,true)

ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(605,142,p.get_data_description,236,238,240,52,58,82)
title= "Average Temperatures during the first months of 2008  "
ch.draw_text_box(0,210,700,230,title,0,255,255,255,Rchart::ALIGN_RIGHT,true,0,0,0,30)
ch.add_border(2)

ch.render_png("Example16")
