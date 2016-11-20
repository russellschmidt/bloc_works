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

	end
end