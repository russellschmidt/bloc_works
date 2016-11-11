require 'test/unit'
require 'rack/test'
require_relative './lib/bloc_works'


class BlocWorksTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		BlocWorks::Application.new
	end

	def test_root
		get '/'
		assert last_response.ok?
	end

end