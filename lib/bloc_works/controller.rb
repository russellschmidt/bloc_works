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
			# if render passed without an action, default to rendering view matching action name
			# else render passed in view name
			
			if args[0].nil? || args[0].is_a?(Hash)
				calling_method = caller[0][/`.*'/][1..-2]
				args.insert(0, calling_method)
				response(create_response_array(*args))
			else
				response(create_response_array(*args))
			end
		end

		def action_match?(action)
			self.class.instance_methods(false).include? action
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
			if status == "302"
				if self.respond_to? target
					routing_params['controller'] = self.class.to_s.split('Controller')[0].downcase
					routing_params['action'] = target.to_s 
					dispatch(target, routing_params)
				elsif target =~ /^([^#]+)#([^#]+)$/
					controller = $1
					action = $2
					routing_params = {"action" => action, "controller" => controller}
					name = controller.capitalize
					controllerName = Object.const_get("#{name}Controller")
					controllerName.dispatch(action, routing_params)
				else
					return [status, {'Content-Type'=>'text/html'}, ['pornotime']]
				end
			else
				puts "Incorrect status code supplied for redirect"
			end
		end
	end
end