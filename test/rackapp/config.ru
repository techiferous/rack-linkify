require 'app'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'rack-linkify')

use Rack::Linkify, :twitter => true

run App.new
