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
		assert_equal "http://localhost:3000/books", last_request.url
		assert last_response.ok?
		assert last_response.body.include?('BlocBooks Below!')
	end

	def test_welcome
		get '/'
		assert_equal "http://localhost:3000", last_request.url
		assert last_response.ok?
		assert last_response.body.include?('Welcome to BlocBooks!')
	end

	def test_show_1
		get '/books/1'
		asset_equal "http://localhost:3000/books/1", last_request.url
		assert last_response.ok?
		assert last_response.body.include?('The Well-Grounded Rubyist')
	end

end