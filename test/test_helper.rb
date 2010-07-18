require 'test/unit'
require 'rubygems'
require 'redgreen'
require 'rack/mock'
require 'rack-linkify'
require 'dirb'
require 'colored'

module Test
  module Unit
    class TestCase

      def linkify_this_html(html)
        app = lambda { |env| [200, {'Content-Type' => 'text/html'}, html] }
        app2 = Rack::Linkify.new(app, :twitter => true)
        Rack::MockRequest.new(app2).get('/', :lint => true).body
      end
  
      def assert_html_equal(expected, actual)
        # Rack::Linkify uses Nokogiri under the hood, which does not
        # preserve the same whitespace between tags when it processes
        # HTML.  This means we can't do a simple string comparison.
        # However, if we run both the expected and the actual
        # through Nokogiri, then the whitespace will be changed in
        # the same way and we can do a simple string comparison.
        expected = Nokogiri::HTML(expected).to_html
        actual = Nokogiri::HTML(actual).to_html
        preamble = "\n"
        preamble =  "*****************************************************\n"
        preamble << "* The actual HTML does not match the expected HTML. *\n"
        preamble << "* The differences are highlighted below.            *\n"
        preamble << "*****************************************************\n"
        message = preamble.magenta
        message << Dirb::Diff.new(expected, actual).to_s(:color)
        assert_block(message) { expected == actual }
      end
      
    end
  end
end
