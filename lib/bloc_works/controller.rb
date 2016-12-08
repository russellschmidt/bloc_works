require 'erubis'

module BlocWorks
	class Controller
		def initialize(env)
			@env = env
			@routing_params = {}
		end

		def dispatch(action, routing_params = {})
			binding.pry
			@routing_params = routing_params
			# copies view to 'text'
			text = self.send(action)
			if has_response?
				rack_response = get_response
				[rack_response.status, rack_response.header, [rack_response.body].flatten]
			else
				[200, {'Content-Type' => 'text/html'}, [text].flatten]
			end
		end

		# Create a new rack object and then call the appropriate controller action
		def self.action(action, response = {})
			proc { |env| self.new(env).dispatch(action, response)}
		end

		def request
			@request ||= Rack::Request.new(@env)
		end

		def params
			request.params.merge(@routing_params)
		end

		def response(text, status=200, headers={})
			raise "Cannot respond multiple times" unless @response.nil?
			# flatten assures that any text sent over is in a 1-D array
			@response = Rack::Response.new([text].flatten, status, headers)
		end

		def render(*args)
			response(create_response_array(*args))
		end

		def create_response_array(view, locals = {})
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

		def get_response
			@response
		end

		def has_response?
			!@response.nil?
		end

		def controller_dir
			klass = self.class.to_s
			klass.slice!("Controller")
			BlocWorks.snake_case(klass)
		end

		def redirect_to(target, status=302, routing_params={})
			# support all three Rails redirect_to main types
			# 1. abs URL 2. action 3. relative links
			if target.match(/^[http:]+\/\//) || target.match(/^[https:]+\/\//)
				response([], status, target)
			elsif routing_params.match(/#{target}/)
				dispatch(target, routing_params)
			else
				[status, {'Location' => target.to_s, 'Content-Type' => 'text/html'},[]]
			end
		end

	end
end