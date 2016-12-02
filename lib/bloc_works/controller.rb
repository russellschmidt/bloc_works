require 'erubis'

module BlocWorks
	class Controller
		def initialize(env)
			@env = env
		end

		def render(view, locals = {})
			filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
			template = File.read(filename)
			eruby = Erubis::Eruby.new(template)
			# get the instance variables of the controller with #instance_variables
			# this returns an array of instance_variables
			# iterate, use #instance_variable_get to get values & add to {locals}
			self.instance_variables.each do |var|
				locals[var] = self.instance_variable_get(var)
			end
			eruby.result(locals.merge(env: @env))
		end

		def controller_dir
			klass = self.class.to_s
			klass.slice!("Controller")
			BlocWorks.snake_case(klass)
		end

		def redirect(location)
			# here because BooksController inherits from BlocWorks::Controller
			# do I need to link this to :call in bloc_works.rb
			[302, {'Location' => location.to_s, 'Content-Type' => 'text/html'}, ['Redirecting']]
			self.render location.to_sym
		end
	end
end