require 'test/test_helper'
require 'rack/mock'
require 'rack-linkify'

class LinkifyTest < Test::Unit::TestCase

  def linkify_this_html(html)
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, html] }
    Rack::MockRequest.new(app).get('/', :lint => true).body
  end
  
  def test_basic_string
    after_html = linkify_this_html('I like turtles')
    assert_equal 'I like turtles', after_html
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
    assert_equal before_html, after_html
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
    assert_equal before_html, after_html
  end

end
