module BlocWorks
	class Application
		def controller_and_action(env)
			# this just returns elements no. 2, 3 & assigns to variables
			# then adjusts to proper naming conventions
			# this becomes a reference to the ExampleController class
			# not just the string 'ExampleController'
			
			_, controller, action, _ = env["PATH_INFO"].split("/", 4)
			controller = controller.capitalize
			controller = "#{controller}Controller"	
			someVar = Object.const_get(controller)
			[someVar, action]
		end

		def fav_icon(env)
			if env['PATH_INFO'] == '/favicon.ico'
				return [404, {'Content-Type' => 'text/html'}, ['404 Not Found']]
			end
		end

		def route(&block)
			@router ||= Router.new
			# #instance_eval - BasicObject instance method
			# evaluates a string or block passed that can be a method or variable
			# of the passed in class.
			@router.instance_eval(&block)
		end

		def get_rack_app(env)
			if @router.nil?
				raise "No routes defined."
			end

			@router.look_up_url(env["PATH_INFO"])
		end
	end

	class Router
		def initialize
			@rules = []
		end

		def map(url, *args)
			@vars, @regex_parts = [], []

			options = map_options(args)
			destination = map_destination(args)
			regex, vars = map_parts(url)

			@rules.push({ regex: Regexp.new("^/#{regex}$"),
										vars: @vars,
										destination: destination,
										options: options })
		end

		def map_options(*args)
			if args[-1].is_a?(Hash)
				options = args.pop 
			else
				options = {}
			end
			options[:default] ||= {}
			options
		end

		def map_destination(*args)
			if args.size == 0
				destination = nil
			else 
				destination = args.pop
				if args.size > 0
					raise 'Too many args. Arrrgh'
				end
			end
			destination
		end

		def map_parts(url)
			# returns two variables: cleaned up url & vars
			regex_parts, vars = [], []
			parts = url.split.delete_if {|p| p.empty?}
			parts.each do |part|
				if part[0] == ":"
					vars << part[1..-1]
					regex_parts << "([a-zA-Z0-9]+)"
				elsif part[0] == "*"
					vars << part[1..-1]
					regex_parts << "(.*)"
				else
					vars << part
				end
			end

			return regex_parts.join("/"), vars
		end

		def look_up_url(url)
			@rules.each do |rule|
				rule_match = rule[:regex].match(url)

				if rule_match
					options = rule[:options]
					params = options[:default].dup

					rule[:vars].each_with_index do |var, index|
						params[var] = rule_match.captures[index]
					end

					if rule[:destination]
						return get_destination(rule[:destination], params)
					else
						controller = params["controller"]
						action = params["action"]
						return get_destination("#{controller}##{action}", params)
					end
				end
			end
		end

		def get_destination(destination, routing_params={})
			if destination.respond_to?(:call)
				return destination
			end

			if destination =~ /^([^#]+)#([^#]+)$/
				name = $1.capitalize
				controller = Object.const_get("#{name}Controller")
				return controller.action($2, routing_params)
			end

			raise "Destination not found: #{destination}"

		end
	end
end