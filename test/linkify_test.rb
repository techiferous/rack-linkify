require 'test/test_helper'
require 'rack/mock'
require 'rack-linkify'
require 'dirb'
require 'colored'

class LinkifyTest < Test::Unit::TestCase

  def linkify_this_html(html)
    app = lambda { |env| [200, {'Content-Type' => 'text/html'}, html] }
    app2 = Rack::Linkify.new(app)
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
    after_html = linkify_this_html(before_html)
    assert_html_equal before_html, after_html
  end

  def test_complex_document
    before_html = %Q{
      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <script src="/javascripts/jquery-1.4.2.min.js?1278100057" type="text/javascript"></script>
          <script src="/javascripts/rails.js?1278100057" type="text/javascript"></script>
          <script src="/javascripts/application.js?1279244644" type="text/javascript"></script>
          <link href="/stylesheets/reset.css?1278100057" media="screen" rel="stylesheet" type="text/css">
          <link href="/stylesheets/application.css?1279312782" media="screen" rel="stylesheet" type="text/css">
          <link href="/stylesheets/print.css?1279244644" media="print" rel="stylesheet" type="text/css">
          <meta name="csrf-param" content="authenticity_token">
          <meta name="csrf-token" content="f69Ldq/NF6OPL30KMTl9jeppLzu4TKYHEC2ZjWbbLro=">
          <title>Geography :: Geographic Curiosities</title>
        </head>
        <body id="main">
          <div id="container">
            <header>
              <h1>Geography Articles</h1>
              <nav>
                <ul>
                  <li><a href="articles.html">Index of all articles</a></li>
                  <li><a href="curiosities.html">Geographic curiosities</a></li>
                  <li><a href="book.html">Buy the book</a></li>
                </ul>
              </nav>
            </header>
            <div>
              <article>
                <header>
                  <h1>Geographic Curiosities</h1>
                </header>
                <section>
                  <h1>Comparitive Locations</h1>
                  <p class="explanation">
                    The relationships of the following cities may surprise you:
                  </p>
                  <ul>
                    <li>Reno, Nevada is farther west than Los Angeles, California.</li>
                    <li>Detroit, Michigan is farther east than Tallahassee, Florida.</li>
                    <li>Tijuana, Mexico is farther north than Hilton Head, South Carolina.</li>
                  </ul>
                </section>
                <section>
                  <h1>North American Countries</h1>
                  <p class="explanation">
                    Did you know about the following North American countries?
                  </p>
                  <ul>
                    <li>Dominica</li>
                    <li>Saint Kitts and Nevis</li>
                    <li>Saint Vincent and the Grenadines</li>
                  </ul>
                </section>
                <footer>
                  <p>Posted <time pubdate datetime="2010-11-04T15:04-08:50">Thursday</time>.</p>
                </footer>
              </article>
              <h2>Sign Up!</h2>
              <form action="/users/signup" class="signup_new_user" id="foo" method="post">
                <div style="margin:0;padding:0;display:inline">
                  <input name="_method" type="hidden" value="put">
                  <input name="authenticity_token" type="hidden" value="f69Ldq/NF6OPL30KMTl9jeppLzu4TKYHEC2ZjWbbLro=">
                </div>
                <div id="title_field" class="field">
                  <label class="aligned_label" for="user[name]">Name</label>
                  <input id="user_name" name="user[name]" size="80" tabindex="1" type="text">
                </div>
                <div class="field">
                  <label class="aligned_label" for="subscription_id">Subscription</label>
                  <select id="subscription_id" name="subscription_id" tabindex="2">
                    <option value="1" selected>1 month</option>
                    <option value="2">6 months</option>
                    <option value="3">1 year</option>
                  </select>
                </div>
                <div class="clearfix">&nbsp;</div>
                <div class="actions">
                  <input id="user_submit" name="commit" tabindex="3" type="submit" value="Sign Up">
                </div>
              </form>
            </div>
            <footer>
              <p>Copyright &copy; 2010 </p>
              <p>
                <a href="about.html">About</a> -
                <a href="policy.html">Privacy Policy</a> -
                <a href="contact.html">Contact Us</a>
              </p>
            </footer>
           </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal before_html, after_html
  end
  
  def test_link_with_http_and_com_domain
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like http://www.google.com and
              http://www.example.com
            </p>
            The following should be linkified:
            <ul>
              <li>http://www.google.com</li>
              <li>http://www.example.com</li>
            </ul>
          </div>
        </body>
      </html>
    }
    target_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like <a href="http://www.google.com">http://www.google.com</a> and
              <a href="http://www.example.com">http://www.example.com</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://www.google.com">http://www.google.com</a></li>
              <li><a href="http://www.example.com">http://www.example.com</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_link_with_http_and_various_tlds
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like http://www.google.net and
              http://www.example.org
            </p>
            The following should be linkified:
            <ul>
              <li>http://www.google.gov</li>
              <li>http://www.example.de</li>
              <li>http://www.example.me</li>
              <li>http://www.example.us</li>
              <li>http://www.example.edu</li>
              <li>http://www.example.info</li>
            </ul>
          </div>
        </body>
      </html>
    }
    target_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like <a href="http://www.google.net">http://www.google.net</a> and
              <a href="http://www.example.org">http://www.example.org</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://www.google.gov">http://www.google.gov</a></li>
              <li><a href="http://www.example.de">http://www.example.de</a></li>
              <li><a href="http://www.example.me">http://www.example.me</a></li>
              <li><a href="http://www.example.us">http://www.example.us</a></li>
              <li><a href="http://www.example.edu">http://www.example.edu</a></li>
              <li><a href="http://www.example.info">http://www.example.info</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_link_with_http_and_paths
    # Note: Linkify does not elegantly handle URLs ending with /.  These URLs are
    # still linkified, but the / ends up outside of the anchor tag.
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like http://www.google.com/foo/bar and
              http://www.google.com/ and http://www.google.com/foo and http://www.google.com/foo/
            </p>
            The following should be linkified:
            <ul>
              <li>http://www.google.com/</li>
              <li>http://www.google.com/foo</li>
            </ul>
          </div>
        </body>
      </html>
    }
    target_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like <a href="http://www.google.com/foo/bar">http://www.google.com/foo/bar</a> and
              <a href="http://www.google.com">http://www.google.com</a>/ and <a href="http://www.google.com/foo">http://www.google.com/foo</a> and <a href="http://www.google.com/foo">http://www.google.com/foo</a>/
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://www.google.com">http://www.google.com</a>/</li>
              <li><a href="http://www.google.com/foo">http://www.google.com/foo</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


end
