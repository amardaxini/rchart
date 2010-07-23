# Playing with line style & pictures inclusion
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([10,9.4,7.7,5,1.7,-1.7,-5,-7.7,-9.4,-10,-9.4,-7.7,-5,-1.8,1.7],"Serie1")
p.add_point([0,3.4,6.4,8.7,9.8,9.8,8.7,6.4,3.4,0,-3.4,-6.4,-8.6,-9.8,-9.9],"Serie2")
p.add_point([7.1,9.1,10,9.7,8.2,5.7,2.6,-0.9,-4.2,-7.1,-9.1,-10,-9.7,-8.2,-5.8],"Serie3")
p.add_point(["Jan","Jan","Jan","Feb","Feb","Feb","Mar","Mar","Mar","Apr","Apr","Apr","May","May","May"],"Serie4")
p.add_all_series()
p.set_abscise_label_serie("Serie4")
p.set_serie_name("Max Average","Serie1")
p.set_serie_name("Min Average","Serie2")
p.set_serie_name("Temperature","Serie3")
p.set_serie_name("Temperature")
p.set_y_axis_name("Temperature")
p.set_x_axis_name("Month of the year")

ch = Rchart.new(700,230)
ch.set_fixed_scale(-12,12,5)
ch.set_font_properties("../fonts/tahoma.ttf",8)
ch.set_graph_area(65,30,570,185)
ch.draw_filled_rounded_rectangle(7,7,693,223,5,240,240,240)
ch.draw_rounded_rectangle(5,5,695,225,5,230,230,230)
ch.draw_graph_area(255,255,255,true)
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2,true,3)
ch.draw_grid(4,true,230,230,230,50)

#draw 0 line
ch.set_font_properties("tahoma.ttf",6)
ch.draw_treshold(0,143,55,72,true,true)

#draw area
p.remove_serie("Serie4")
ch.draw_area(p.get_data, "Serie1", "Serie2", 239,238,227,50)
p.remove_serie("Serie3")
ch.draw_line_graph(p.get_data,p.get_data_description)

#draw line graph
ch.set_line_style(1,6)
p.remove_all_series
p.add_serie("Serie3")
ch.draw_line_graph(p.get_data,p.get_data_description)
ch.draw_plot_graph(p.get_data,p.get_data_description,3,2,255,255,255)

#write values on serie3
ch.set_font_properties("tahoma.ttf",8)
ch.write_values(p.get_data,p.get_data_description, "Serie3")

#Finish the graph
ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(590,90,p.get_data_description,255,255,255)
ch.set_font_properties("tahoma.ttf",10)
ch.draw_title(60,22,"Example 15",50,50,50,585)
ch.draw_from_png("logo.png",584,35)
ch.render_png("example12")
