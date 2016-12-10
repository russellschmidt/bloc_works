require 'test/unit'
require 'rack/test'
require_relative './lib/bloc_works'

class BlocWorksTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		BlocWorks::Application.new
	end

	def test_favicon
		get '/favicon.ico'

		assert_equal last_response.status, 404
	end

	def test_books
		get '/books'
		asset_equal "http://localhost:3000/books", last_request.url
		assert last_response.ok?
	end

	def test_map
		get '/books'
		assert last_response.body.include?('Welcome to BlocBooks!')
	end

	def test_look_up
		get '/books'
	end

end