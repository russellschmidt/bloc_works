require 'erubis'

module BlocWorks
	class Controller
		def initialize(env)
			@env = env
			@routing_params = {}
		end

		def dispatch(action, routing_params = {})
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
			# auto render views that have matching name to controller action
			# check that the action is a controller action
			# then check if there is a view that matches, and if so, render
			# otherwise we use our standard rendering

			# if action_match?(args[0]) && view_match?(args[0])
			# 	render_matched_view(args)
			# else
			response(create_response_array(*args))
			# end
		end

		def action_match?(action)
			self.class.instance_methods(false).include? action
		end

		def view_match?(action)
			@filename = File.join("app", "views", controller_dir, "#{action}.html.erb")
			File.file?(@filename)
		end

		def render_matched_view(*args)
			template = File.read(@filename)
			eruby = Erubis::Eruby.new(template)
			locals = args[1].nil? ? {} : args[1]
			self.instance_variables.each do |var|
				locals[var] = self.instance_variable_get(var)
			end
			eruby.result(locals.merge(env: @env))		
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

		def redirect_to(target, status="302", routing_params={})
			# Rails supports redirect to:
			# 1. abs URL 2. action different controller 3. action same controller 4. relative links
			if status == "302"
				if target.match(/^[http:]+\/\//) || target.match(/^[https:]+\/\//)
					return [status, {'Location' => target.to_s, 'Content-Type' => 'text/html'},[]]
				elsif target.match(/_/)
					# if redirect target in rails format: controller_action
					# => change routing_params to the controller, action
					# => call dispatch with action, new routing_params
					controller, action = target.split('_')
					
					routing_params = {"action" => action.to_s, "controller" => controller.to_s}
					dispatch(action.to_sym, routing_params)
				elsif !routing_params[target].nil?
					dispatch(target, routing_params)
				else
					return [status, {'Location' => target.to_s, 'Content-Type' => 'text/html'},[]]
				end
			else
				"Incorrect status code supplied for redirect"
			end
		end

	end
end