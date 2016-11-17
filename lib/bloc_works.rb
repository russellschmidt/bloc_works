require_relative "bloc_works/version"
require_relative "bloc_works/controller"
require_relative "bloc_works/dependencies"
require_relative "bloc_works/utility"
require_relative "bloc_works/router"

module BlocWorks
  class Application

  	def call(env)
  		puts '*** hi 1'
  		response = self.fav_icon(env)
  		puts '*** hi 2'
  		if response
  			return response
  		else
  			puts '*** hi 3'
  			puts self.controller_and_action(env)
  			cont_array = self.controller_and_action(env)
  			puts '*** hi 4'
  			cont = cont_array.first.new(env)
  			action_call = cont.send(cont_array.last)
  			puts action_call
  			return action_call
  		end
  	end
  end
end
