#Two Y axis / shadow demonstration
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([110,101,118,108,110,106,104],"Serie1")
p.add_point([700,2705,2041,1712,2051,846,903],"Serie2")
p.add_point(["03 Oct","02 Oct","01 Oct","30 Sep","29 Sep","28 Sep","27 Sep"],"Serie3")
p.add_serie("Serie1")
p.set_abscise_label_serie("Serie3")
p.set_serie_name("SourceForge Rank","Serie1")
p.set_serie_name("Web Hits","Serie2")


ch = Rchart.new(660,230)
ch.draw_graph_area_gradient(90,90,90,90,Rchart::TARGET_BACKGROUND)
ch.set_font_properties("tahoma.ttf",8)
ch.set_graph_area(60,40,595,190)
ch.set_font_properties("tahoma.ttf",8)
 # Draw the SourceForge Rank graph
p.set_y_axis_name("SourceForge Rank")
ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,213,217,221,true,0,0)
ch.draw_graph_area_gradient(40,40,40,-50)
ch.draw_grid(4,true,230,230,230,10)

ch.set_shadow_properties(3,3,0,0,0,30,4)
ch.draw_cubic_curve(p.get_data,p.get_data_description)
ch.clear_shadow
ch.draw_filled_cubic_curve(p.get_data,p.get_data_description,0.1,30)
ch.draw_plot_graph(p.get_data,p.get_data_description,3,2,255,255,255)
ch.clear_scale

#draw 2nd graph
p.remove_serie("Serie1")
p.add_serie("Serie2")
p.set_y_axis_name("Web Hits")

ch.draw_right_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,213,217,221,true,0,0)
ch.draw_grid(4,true,230,230,230,10)
ch.set_shadow_properties(3,3,0,0,0,30,4)
ch.draw_cubic_curve(p.get_data,p.get_data_description)
ch.clear_shadow
ch.draw_filled_cubic_curve(p.get_data,p.get_data_description,0.1,30)
ch.draw_plot_graph(p.get_data,p.get_data_description,3,2,255,255,255)
ch.clear_scale


ch.set_font_properties("tahoma.ttf",8)
ch.draw_legend(530, 5, p.get_data_description, 0,0,0,0,0,0,255,255,255,false)

ch.set_font_properties("MankSans.ttf",18)
ch.set_shadow_properties(1,1,0,0,0)
ch.draw_title(0,0,"SourceForge ranking summary",255,255,255,660,30,true)
ch.clear_shadow

ch.render_png("example21")
