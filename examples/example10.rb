#A 2D exploded pie graph
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([10,2,3,5,3],"Serie1")
p.add_point(["Jan","Feb","Mar","Apr","May"],"Serie2")
p.add_all_series
p.set_abscise_label_serie("Serie2")

ch = Rchart.new(300,200)
ch.set_font_properties("tahoma.ttf",8)
ch.draw_filled_rounded_rectangle(7,7,293,193,5,240,240,240)
ch.draw_rounded_rectangle(5,5,295,195,5,230,230,230)

# Draw the pie chart
ch.antialias_quality=0
ch.set_shadow_properties(2,2,200,200,200)
ch.draw_flat_pie_graph_with_shadow(p.get_data,p.get_data_description,120,100,60,Rchart::PIE_PERCENTAGE,8)
ch.clear_shadow
ch.draw_pie_legend(230,15,p.get_data,p.get_data_description,250,250,250)

ch.render_png("example10")
