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




end