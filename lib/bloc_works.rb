require_relative "bloc_works/version"
require_relative "bloc_works/dependencies"
require_relative "bloc_works/controller"
require_relative "bloc_works/utility"
require_relative "bloc_works/router"

module BlocWorks
  class Application
  	def call(env)
  		response = self.fav_icon(env)  		

			controller_array = self.controller_and_action(env)
			controller = controller_array.first.new(env)
			content = controller.send(controller_array.last)

      if controller.has_response?
        status, header, response = controller.get_response
        [status, header, [response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [content]]
      end
  	end
  end
end
