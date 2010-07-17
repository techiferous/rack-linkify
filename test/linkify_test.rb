require 'test/test_helper'
require 'rack/mock'
require 'rack-linkify'

class LinkifyTest < Test::Unit::TestCase

  def linkify_this_html(html)
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, html] }
    response = Rack::MockRequest.new(app).get('/', :lint => true)
  end

  def test_basic_string
    response = linkify_this_html('I like turtles')
    assert_equal 200, response.status
    assert_equal 'I like turtles', response.body
  end

end
