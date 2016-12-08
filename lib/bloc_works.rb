require_relative "bloc_works/version"
require_relative "bloc_works/dependencies"
require_relative "bloc_works/controller"
require_relative "bloc_works/utility"
require_relative "bloc_works/router"

module BlocWorks
  class Application
  	def call(env)
      # binding.pry
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end

      rack_app = get_rack_app(env)
      rack_app.call(env)

  	end
  end
end
