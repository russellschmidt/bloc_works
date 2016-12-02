require_relative "bloc_works/version"
require_relative "bloc_works/dependencies"
require_relative "bloc_works/controller"
require_relative "bloc_works/utility"
require_relative "bloc_works/router"

module BlocWorks
  class Application
  	def call(env)
  		response = self.fav_icon(env)
  		
  		if response
  			return response
  		else
  			cont_array = self.controller_and_action(env)
  			cont = cont_array.first.new(env)
  			action_call = cont.send(cont_array.last)
  			return [200, {'Content-Type' => 'text/html'}, [action_call]]
  		end
  	end
  end
end
