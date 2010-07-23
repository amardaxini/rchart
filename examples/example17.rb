#Customizing plot graphs

require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([60,70,90,110,100,90],"Serie1")
p.add_point([40,50,60,80,70,60],"Serie2")
p.add_point(["Jan","Feb","Mar","Apr","May","Jun"],"Serie3")
p.add_serie("Serie1")
p.add_serie("Serie2")

p.set_abscise_label_serie("Serie3")
p.set_serie_name("Company A","Serie1")
p.set_serie_name("Company B","Serie2")
p.set_y_axis_name("Product sales")
p.set_y_axis_unit("k")
p.set_serie_symbol("Serie1","Point_Asterisk.png")
p.set_serie_symbol("Serie2","Point_Cd.png")

ch = Rchart.new(700,230)
ch.set_font_properties("tahoma.ttf",8)
ch.set_graph_area(65,30,650,200)
ch.draw_filled_rectangle(7,7,693,223,5,240,240,240)
ch.draw_rounded_rectangle(5,5,695,225,5,230,230,230)
ch.draw_graph_area(255,255,255,true)

ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2,true)
ch.draw_grid(4,true,230,230,230,20)
ch.set_font_properties("pf_arma_five.ttf",6)
title= "Comparative product sales for company A & B  "
ch.draw_text_box(65,30,650,45,title,0,255,255,255,Rchart::ALIGN_RIGHT,true,0,0,0,30)

# Draw the line chart
ch.draw_line_graph(p.get_data,p.get_data_description)
ch.draw_plot_graph(p.get_data,p.get_data_description,3,2,255,255,255)
ch.draw_treshold(0,143,55,72,true,true)
ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(80,60,p.get_data_description,255,255,255)

ch.render_png("Example17")
