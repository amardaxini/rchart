# A smooth flat pie graph
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([10,2,3,5,3],"Serie1")
p.add_point(["Jan","Feb","Mar","Apr","May"],"Serie2")
p.add_all_series
p.set_abscise_label_serie("Serie2")

ch = Rchart.new(300,200)
ch.draw_filled_rounded_rectangle(7,7,293,193,5,240,240,240)
ch.draw_rounded_rectangle(5,5,295,195,5,230,230,230)
#ch.load_color_palette_from_file("softtones.txt") #OR
ch.load_color_palette([[168,188,56],[188,208,76],[208,228,96],[228,245,116],[248,255,136]])
ch.draw_filled_circle(122,102,70,200,200,200)
ch.set_font_properties("tahoma.ttf",8)

ch.draw_basic_pie_graph(p.get_data,p.get_data_description,120,100,70,Rchart::PIE_PERCENTAGE,255,255,218)
ch.draw_pie_legend(230,15,p.get_data,p.get_data_description,250,250,250)

ch.render_png("example11")
