module BlocWorks
	class Application
		def controller_and_action(env)
			# this just returns elements no. 2, 3 & assigns to variables
			_, controller, action, _ = env["PATH_INFO"].split("/", 4)
			# use proper naming conventions
			controller = controller.capitalize
			controller = "#{controller}Controller"

			# this becomes a reference to the ExampleController class
			# not just the string 'ExampleController'
			[Object.const_get(controller), action]
		end

		def fav_icon(env)
			if env['PATH_INFO'] == '/favicon.ico'
				content = "<DOCTYPE! html><html><head></head><body><h1>404</h1><h2>Page Not Found Sorry bud</h2></body></html>"
				return [404, {'Content-Type' => 'text/html'}, [content]]
			end
		end
	end
end