#MISSING VALUES
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([2,5,7,"","",5,6,4,8,4,"",2,5,6,4,5,6,7,6],"Serie1")
p.add_point([-1,-3,-1,-2,-4,-1,"",-4,-5,-3,-2,-2,-3,-3,-5,-4,-3,-1,""],"Serie2")
p.add_all_series()
p.set_abscise_label_serie
p.set_serie_name("Raw #1","Serie1")
p.set_serie_name("Raw #2","Serie2")
p.set_y_axis_name("Response Time")
p.set_x_axis_name("Sample #ID")

ch = Rchart.new(700,230)
ch.set_font_properties("tahoma.ttf",8)
ch.set_graph_area(55,30,585,185)
ch.draw_filled_rounded_rectangle(7,7,693,223,5,240,240,240)
ch.draw_rounded_rectangle(5,5,695,225,5,230,230,230)
ch.draw_graph_area(255,255,255,true)
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2,true)
ch.draw_grid(4,true,230,230,230,50)

#draw 0 line
ch.set_font_properties("tahoma.ttf",6)
ch.draw_treshold(0,143,55,72,true,true)

#draw line graph
p.remove_serie("Serie2")
ch.draw_filled_line_graph(p.get_data,p.get_data_description,60,true)

#draw curve graph
p.remove_serie("Serie1")
p.add_serie("Serie2")
ch.set_shadow_properties(2,2,200,200,200,50)
ch.draw_cubic_curve(p.get_data, p.get_data_description)
ch.draw_plot_graph(p.get_data,p.get_data_description,3,2,255,255,255)
ch.clear_shadow

#Finish the graph
ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(600,30,p.get_data_description,255,255,255)
ch.set_font_properties("tahoma.ttf",10)
ch.draw_title(50,22,"Example 13",50,50,50,585)
ch.render_png("example13")
