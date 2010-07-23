 #A 3D exploded pie graph
require 'rubygems'
require 'rchart'

p = Rdata.new
p.add_point([10,2,3,5,3],"Serie1")
p.add_point(["January","February","March","April","May"],"Serie2")
p.add_all_series
p.set_abscise_label_serie("Serie2")

ch = Rchart.new(420,250)
ch.draw_filled_rounded_rectangle(7,7,413,243,5,240,240,240)
ch.draw_rounded_rectangle(5,5,415,245,5,230,230,230)
ch.create_color_gradient_palette(195,204,56,223,110,41,5)
ch.set_font_properties("tahoma.ttf",8)
ch.antialias_quality=0


ch.draw_basic_pie_graph(p.get_data, p.get_data_description, 180, 130,110)
ch.draw_pie_graph(p.get_data,p.get_data_description,180,130,110,Rchart::PIE_PERCENTAGE_LABEL,false,50,20,5)
ch.draw_pie_legend(330,15,p.get_data,p.get_data_description,250,250,250)

#Write the title
ch.set_font_properties("MankSans.ttf",10)
ch.draw_title(10,20,"Sales per month",100,100,100)
ch.render_png("example6")
