require 'rubygems'
require 'ruby-debug'
class Version
	MAJOR = 1
	MINOR = 0
	RELEASE = 0
	def self.current
		"#{MAJOR}.#{MINOR}.#{RELEASE}"
	end
	def self.font_path
		Gem.path.each do |gem_path|
			path= gem_path+"/gems/rchart-#{MAJOR}.#{MINOR}.#{RELEASE}/fonts"
			if File.exists?(path+"/tahoma.ttf")
				return  path
				break
			end
		end
	end
end
