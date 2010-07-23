#X versus Y char
require 'rubygems'
require 'rchart'
#Compute the points
p = Rdata.new
i=0
while(i<=360)
	p.add_point(Math.cos(i*Math::PI/180)*80+i,"Serie1")
	p.add_point(Math.sin(i*Math::PI/180)*80+i,"Serie2")
	i+=10

end
p.set_serie_name("Trigonometric function","Serie1")
p.add_serie("Serie1")
p.add_serie("Serie2")
p.set_x_axis_name("X Axis")
p.set_y_axis_name("Y Axis")
ch = Rchart.new(300,300)
ch.draw_graph_area_gradient(0,0,0,-100,Rchart::TARGET_BACKGROUND);
ch.set_font_properties("tahoma.ttf",8)
ch.set_graph_area(55,30,270,230)
ch.draw_xy_scale(p.get_data,p.get_data_description,"Serie1","Serie2",213,217,221,true,45)
ch.draw_graph_area(213,217,221,false)
ch.draw_graph_area_gradient(30,30,30,-50);
ch.draw_grid(4,true,230,230,230,20)
ch.set_shadow_properties(2,2,0,0,0,60,4)

ch.draw_xy_graph(p.get_data,p.get_data_description,"Serie1","Serie2",0)
ch.clear_shadow

title= "Drawing X versus Y charts trigonometric functions  ";
ch.draw_text_box(0,280,300,300,"#{title}",0,255,255,255,Rchart::ALIGN_RIGHT,true,0,0,0,30)
ch.set_font_properties("pf_arma_five.ttf",6)
p.remove_serie("Serie2")
ch.draw_legend(160,5,p.get_data_description,0,0,0,0,0,0,255,255,255,false)
ch.render_png("example19")
