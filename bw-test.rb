require 'test/unit'
require 'rack/test'
require_relative './lib/bloc_works'


class BlocWorksTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		BlocWorks::Application.new
	end

	def test_call
		get '/'
		assert last_response.ok?
		assert_equal "<DOCTYPE html><html><head></head><body><h1 style='text-align:center;'>Hello Blocheads!</h1><div><img src='https://goo.gl/7mbPVM' alt='bully bulldog'></div></body></html>", last_response.body
	end

end