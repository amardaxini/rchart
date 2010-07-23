# Showing how to use labels
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([0,70,70,0,0,70,70,0,0,70],"Serie1")
p.add_point([0.5,2,4.5,8,12.5,18,24.5,32,40.5,50],"Serie2")
p.add_all_series()
p.set_abscise_label_serie
p.set_serie_name("January","Serie1")
p.set_serie_name("February","Serie2")

ch = Rchart.new(700,230)
ch.set_font_properties("../fonts/tahoma.ttf",8)
ch.set_graph_area(50,30,585,200)
ch.draw_filled_rounded_rectangle(7,7,693,223,5,240,240,240)
ch.draw_rounded_rectangle(5,5,695,225,5,230,230,230)
ch.draw_graph_area(255,255,255,true)
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2)
ch.draw_grid(4,true,230,230,230,50)
ch.set_font_properties("../fonts/tahoma.ttf",6)
ch.draw_treshold(0,143,55,72,true,true)

#draw line graph
ch.draw_line_graph(p.get_data,p.get_data_description)
ch.draw_plot_graph(p.get_data, p.get_data_description,3,2,255,255,255)

# Set labels
ch.set_font_properties("../fonts/tahoma.ttf",8)
ch.set_label(p.get_data, p.get_data_description, "Serie1", "2","Daily incomes",221,230,174)
ch.set_label(p.get_data, p.get_data_description, "Serie2", "6","Production break",239,233,195)

ch.set_font_properties("../fonts/tahoma.ttf",8)
ch.draw_legend(600,30,p.get_data_description,255,255,255)
ch.set_font_properties("../fonts/tahoma.ttf",10)
ch.draw_title(50,22,"Example 5",50,50,50,585)
ch.render_png("example5")
