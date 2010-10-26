class Rdata
# This function create a new Rdata object.
# This object will be used during all the steps of the data population.
# Data will be extracted from this object using get_data and get_data_description 
	def initialize
		@data                          = []
		@data_description              = {}
		@data_description["position"]  = "name"
		@data_description["format"]    = {"x"=>"number","y" => "number"}
		@data_description["unit"]      = {"x" => "","y"=>""}
		@data_description["symbol"] = {}
	end

	# This function can be used to add one or multiple points to a data serie.
	# By default points are added to Serie1.
	# This will the value 25 as the last point of Serie1
	# * chart_data.add_point(25)
	# This will the value 2,4,9,5,1,0 as the last point of Serie1
	# * chart_data.add_point([2,4,9,5,1,0])
	# This will the value 12 as the last point of Serie2
	# * chart_data.add_point(12,"Serie2")
	# add the desciption "March" to the Serie2
	# * chart_data.add_point(12,"Serie2","March")
	def add_point(value,serie="Serie1",description="")
		if ((value.is_a?(Array)) && value.count == 1)
			value = value[0]
		end
		id = 0
		@data.each_with_index do |v,index|
			id = index+1  unless @data[index][serie].nil?
		end
		if value.is_a?(Numeric)
			if @data[id].nil?
				@data[id]={serie => value}
			else
				@data[id]= @data[id].merge(serie => value)
			end
			if description != ""
				@data[id]["name"] = description;
			elsif @data[id]["name"].nil?
				@data[id]["name"] = id
			end
		else

			value.each do |k|
				if @data[id].nil?
					@data[id] = {serie=>k}#TODO check k
				else
					@data[id] = @data[id].merge({serie=>k})
				end

				@data[id]["name"] = id  if @data[id]["name"].nil?
				id = id+1
			end

		end

	end
	# This function can be used to add a new data serie to the data_description.
	# All the series declared in this object will be graphed when calling a chart function of the Rchart class.
	# There is no change on Data, only the "Graphable" attribute is modified.
	# Generate some data...
	# * chart_data.add_point([2,4,9,5,1,0]),"Serie1")
	# * chart_data.add_point([1,1,2,2,3,3]),"Serie2")
	# * chart_data.add_point([4,2,4,2,4,2]),"Serie3")
	# This will mark both Serie1 & Serie2 as "graphable" but not Serie3
	# * chart_data.add_serie("Serie1")
	# * chart_data.add_serie("Serie2")
	def add_serie(serie_name="Serie1")

		if (@data_description["values"].nil?)
			@data_description["values"]  = [serie_name]
		else
			found = false
			@data_description["values"].each do |k|
				found = true if ( k == serie_name )  #TODO check
			end
			@data_description["values"] << serie_name if (!found )
		end

	end
	# This function can be used to set all data series as graphable.
	# They'll all be graphed when calling a chart function of the Rchart class.
	# There is no change on Data, only the "Graphable" attribute is modified
	# Generate some data...
	# * chart_data.add_point([2,4,9,5,1,0],"Serie1")
	# * chart_data.add_point([(1,1,2,2,3,3],"Serie2")
	# This will mark both Serie1 & Serie2 as "graphable"  
	# * chart_data.add_all_series
	
	def add_all_series
		@data_description["values"] = []
		if(!@data[0].nil?)
			@data[0].each do |k,v|
				if (k != "name" )
					@data_description["values"].push(k)
				end
			end
		end
	end
	# This function can be used to remove a data series from the graphable ones.
	# They'll all be graphed when calling a chart function of the Rchart class.
	# There is no change on Data, only the "Graphable" attribute is modified.
	# Generate some data...
	# * chart_data.add_point([2,4,9,5,1,0],"Serie1")
	# * chart_data.add_point([1,1,2,2,3,3],"Serie2")
	# This will mark both Serie1 & Serie2 as "graphable"
	# * chart_data.add_all_series
	# This will remove the "graphable" status of Serie2
	# * chart_data.remove_serie("Serie2")
	
	def remove_serie(serie_name="Serie1")
		if (!@data_description["values"].nil?)
			found = false;
			@data_description["values"].each do |v|
				@data_description["values"].delete(v)  if (v == serie_name )
			end
		end
	end
	# his function can be used to set which serie is used (if any) as abcisse value
	# Generate some data...
	# * chart_data.add_point(["Jan","Feb","Mar"),"Serie1")
	# * chart_data.add_point([2,4,9),"Serie2")
	# * chart_data.add_point([1,1,2),"Serie3")
	# This will mark both Serie1 & Serie2 as "graphable"
	# * chart_data.add_serie("Serie2")
	# * chart_data.add_serie("Serie3")
	# Set Serie as abcisse label
	# * chart_data.set_abscise_label_serie("Serie1")  
	def set_abscise_label_serie(serie_name = "name")
		@data_description["position"] = serie_name
	end
 # This function can be used to set the description of a serie.
 # This description will be written on the graph when calling the draw_legend function
 # Generate some data...
 # * chart_data.add_point([2,4,9),"Serie1")
 # * chart_data.add_point([1,1,2),"Serie2")
 # This will set the name of Serie1 to "January"
 # * chart_data.set_serie_name("January")
 # This will set the name of Serie2 to "February"
 # * chart_data.set_serie_name("February","Serie2")
	
	def set_serie_name(name,serie_name="Serie1")
		if @data_description["description"].nil?
			@data_description["description"]={serie_name => name}
		else
			@data_description["description"] = @data_description["description"].merge(serie_name => name)
		end
	end

	# This will give a name to the X axis, writting it horizontally behind the chart
	# * chart_data.set_x_axis_name("Samples")
	def set_x_axis_name(name="X Axis")
		if @data_description["axis"].nil?
			@data_description["axis"]={"x" => name}
		else
			@data_description["axis"]=@data_description["axis"].merge("x" => name)
		end
	end
	# This will give a name to the Y axis, writting it horizontally behind the chart
	# * chart_data.set_y_axis_name("Temperature") 
	def set_y_axis_name(name="Y Axis")
		if @data_description["axis"].nil?
			@data_description["axis"]= {"y" => name}
		else
			@data_description["axis"]=@data_description["axis"].merge("y" => name)
		end
	end

# With this function you can set the format of the X axis values. Todays formats are the following :
# * number used by defaults
# * metric number that will be displayed with k/m/g units

	def set_x_axis_format(format="number")
		@data_description["format"]["x"] = format
	end
# With this function you can set the format of the Y axis values. Todays formats are the following :
# * number used by defaults
# * metric number that will be displayed with k/m/g units

	def set_y_axis_format(format="number")
		@data_description["format"]["y"] = format
	end
# Set the axis unit. This will be appended to the axis value
# Give the "km" unit to the X axis
# * chart_data.set_x_axis_unit("km")
	def set_x_axis_unit(unit="")
		@data_description["unit"]["x"] = unit
	end
	
# Set the axis unit. This will be appended to the axis value
# Give the "m/s" unit to the Y axis
# * chart_data.set_x_axis_unit("m/s")
	
	def set_y_axis_unit(unit="")
		@data_description["unit"]["y"] = unit
	end

	def set_serie_symbol(name,symbol)
		@data_description["symbol"][name] = symbol
	end
	# This function can be used to remove the description of a serie.
	# This description will be written on the graph when calling the drawLegend function.
	# Removing it's name using this function can be usefull to hide previously used series
	# Generate some data...
	# * chart_data.add_point([2,4,9],"Serie1")
	# * chart_data.add_point([1,1,2],"Serie2")
	# This will set the name of Serie1 to "January"
	# * chart_data.set_serie_name("January")
	# This will set the name of Serie2 to "February"
	# * chart_data.set_serie_name("February","Serie2")
	# Ths will remove name of Serie1
	# * chart_data.remove_serie_name("Serie1")
	def remove_serie_name(serie_name)
		if(!@data_description["description"][serie_name].nil?)
			@data_description["description"].delete(serie_name)
		end
	end
	# This function can be used to remove the description of a serie.
	# This description will be written on the graph when calling the drawLegend function.
	# Removing it's name using this function can be usefull to hide previously used series
	
	def remove_all_series
		@data_description["values"].each do |v|
			@data_description["values"] = []
		end
	end

	# This function is used everytime you want to retrieve the Data stored in the Rdata structure
	def get_data
		@data
	end
	# This function is used everytime you want to retrieve the Data description stored in the Rdata structure 
	def get_data_description
		@data_description
	end

end

