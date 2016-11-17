class Object
	def self.const_missing(const)
		
		# convert unfound const to a properly formatted string and check again
		require BlocWorks.snake_case(const.to_s)
		Object.const_get(const)
	end
end