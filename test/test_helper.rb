require 'test/unit'
require 'rubygems'
require 'redgreen'
require 'rack-linkify'
require 'plastic_test_helper'

module Test
  module Unit
    class TestCase
      
      include PlasticTestHelper

      def linkify_this_html(html)
        process_html(html, Rack::Linkify, :twitter => true)
      end
  
    end
  end
end
