#Playing with shadow
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
ch.draw_graph_area_gradient(90,90,90,90,Rchart::TARGET_BACKGROUND)
ch.set_fixed_scale(0,40,4)
ch.set_font_properties("pf_arma_five.ttf",6)
ch.set_graph_area(60,40,680,200)
ch.draw_graph_area(200,200,200,false)
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,213,217,221,true,0,2)
ch.draw_graph_area_gradient(40,40,40,-50)
ch.draw_grid(4,true,230,230,230,10)

 # Draw the line chart
ch.set_shadow_properties(3,3,0,0,0,30,4)
ch.draw_cubic_curve(p.get_data,p.get_data_description)
ch.clear_shadow
ch.draw_plot_graph(p.get_data,p.get_data_description,4,2,-1,-1,-1,true)

ch.set_font_properties("MankSans.ttf",18)
ch.set_shadow_properties(1,1,0,0,0)
ch.draw_title(0,0,"Average temperatures",255,255,255,700,30,true)
ch.clear_shadow

ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(610, 5, p.get_data_description, 0,0,0,0,0,0,255,255,255,false)
ch.render_png("example20")
