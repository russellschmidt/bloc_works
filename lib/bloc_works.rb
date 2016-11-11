require_relative "bloc_works/version"

module BlocWorks
  class Application
  	def call(env)
  		my_content = "<DOCTYPE html><html><head></head><body><h1 style='text-align:center;'>Hello Blocheads!</h1><div><img src='https://goo.gl/7mbPVM' alt='bully bulldog'></div></body></html>"

  		[200, {'Content-Type'=>'text/html'}, [my_content]]
  	end
  end
end
