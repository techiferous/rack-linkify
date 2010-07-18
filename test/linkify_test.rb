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

  def test_basic_document
    before_html = %Q{
      <!DOCTYPE html
      PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
        <head>
          <title>Testing Rack::Linkify</title>
        </head>
        <body>
          Hi, Mom!
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html).body
    assert_equal before_html, after_html
  end

end
