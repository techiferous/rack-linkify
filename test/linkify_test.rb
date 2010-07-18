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
  
  def test_links_with_http_and_com_domain
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


  def test_links_with_http_and_various_tlds
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


  def test_links_with_http_and_paths
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


  def test_links_with_https
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like https://www.google.com and
              https://www.example.com
            </p>
            The following should be linkified:
            <ul>
              <li>https://www.google.com</li>
              <li>https://www.example.com</li>
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
              This test should linkify links like <a href="https://www.google.com">https://www.google.com</a> and
              <a href="https://www.example.com">https://www.example.com</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="https://www.google.com">https://www.google.com</a></li>
              <li><a href="https://www.example.com">https://www.example.com</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_without_http
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like www.google.com and
              www.example.gov
            </p>
            The following should be linkified:
            <ul>
              <li>www.google.com</li>
              <li>www.example.gov</li>
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
              This test should linkify links like <a href="http://www.google.com">www.google.com</a> and
              <a href="http://www.example.gov">www.example.gov</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://www.google.com">www.google.com</a></li>
              <li><a href="http://www.example.gov">www.example.gov</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_without_subdomains
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like google.com and
              example.gov
            </p>
            The following should be linkified:
            <ul>
              <li>google.com</li>
              <li>example.gov</li>
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
              This test should linkify links like <a href="http://google.com">google.com</a> and
              <a href="http://example.gov">example.gov</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://google.com">google.com</a></li>
              <li><a href="http://example.gov">example.gov</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_with_varied_subdomains
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like sub.google.com and
              foo.bar.baz.example.gov
            </p>
            The following should be linkified:
            <ul>
              <li>sub.google.com</li>
              <li>foo.bar.baz.example.gov</li>
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
              This test should linkify links like <a href="http://sub.google.com">sub.google.com</a> and
              <a href="http://foo.bar.baz.example.gov">foo.bar.baz.example.gov</a>
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://sub.google.com">sub.google.com</a></li>
              <li><a href="http://foo.bar.baz.example.gov">foo.bar.baz.example.gov</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_followed_by_commas
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like sub.google.com,
              http://www.google.com, http://example.gov/foo/bar, and
              https://some.domain.example.com, even though they are
              followed by punctuation.
            </p>
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
              This test should linkify links like <a href="http://sub.google.com">sub.google.com</a>,
              <a href="http://www.google.com">http://www.google.com</a>, <a href="http://example.gov/foo/bar">http://example.gov/foo/bar</a>, and
              <a href="https://some.domain.example.com">https://some.domain.example.com</a>, even though they are
              followed by punctuation.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_followed_by_punctuation
    # Note: if URLs are followed by a hyphen that is punctuation and not a part of
    # the URL, Linkify will treat it as part of the URL.  This is not the ideal
    # behavior, but it is very hard to detect this scenario since hyphens are
    # a valid part of URLs.
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like sub.google.com?
              http://www.google.com. http://example.gov/foo/bar! and
              https://some.domain.example.com: even though they are
              followed by punctuation.
            </p>
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
              This test should linkify links like <a href="http://sub.google.com">sub.google.com</a>?
              <a href="http://www.google.com">http://www.google.com</a>. <a href="http://example.gov/foo/bar">http://example.gov/foo/bar</a>! and
              <a href="https://some.domain.example.com">https://some.domain.example.com</a>: even though they are
              followed by punctuation.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_links_among_parentheses
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like
              (http://www.google.com) and (http://example.gov/foo/bar)
              even though they are surrounded by parentheses.
            </p>
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
              This test should linkify links like
              (<a href="http://www.google.com">http://www.google.com</a>) and (<a href="http://example.gov/foo/bar">http://example.gov/foo/bar</a>)
              even though they are surrounded by parentheses.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_variety_of_links
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p id="explanation">
              The following is a collection of typical links you would come across.
            </p>
            <p>
              The following links should be linkified:
              http://www.w3schools.com/tags/att_a_href.asp as well as
              http://www.google.com/#hl=en&source=hp&q=what+is+a+spork&aq=f&aqi=l1g1&aql=&oq=&gs_rfai=Cmg1v-jxDTK_FOoGOzQT2jtnPCgAAAKoEBU_QannZ&fp=6f146f4f6152193c
              and http://stackoverflow.com/questions/tagged/linux
              and finally http://www.cnn.com/2010/POLITICS/07/18/tea.party.imbroglio/index.html?hpt=T2.
            </p>
          </div>
        </body>
      </html>
    }
    target_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p id="explanation">
              The following is a collection of typical links you would come across.
            </p>
            <p>
              The following links should be linkified:
              <a href="http://www.w3schools.com/tags/att_a_href.asp">http://www.w3schools.com/tags/att_a_href.asp</a> as well as
              <a href="http://www.google.com/#hl=en&source=hp&q=what+is+a+spork&aq=f&aqi=l1g1&aql=&oq=&gs_rfai=Cmg1v-jxDTK_FOoGOzQT2jtnPCgAAAKoEBU_QannZ&fp=6f146f4f6152193c">http://www.google.com/#hl=en&source=hp&q=what+is+a+spork&aq=f&aqi=l1g1&aql=&oq=&gs_rfai=Cmg1v-jxDTK_FOoGOzQT2jtnPCgAAAKoEBU_QannZ&fp=6f146f4f6152193c</a>
              and <a href="http://stackoverflow.com/questions/tagged/linux">http://stackoverflow.com/questions/tagged/linux</a>
              and finally <a href="http://www.cnn.com/2010/POLITICS/07/18/tea.party.imbroglio/index.html?hpt=T2">http://www.cnn.com/2010/POLITICS/07/18/tea.party.imbroglio/index.html?hpt=T2</a>.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_more_variety_of_links
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p id="explanation">
              The following is a collection of even more links you would come across.
            </p>
            <p>
              The following links should be linkified:
              http://www.youtube.com/watch?v=_OBlgSz8sSM and
              http://maps.google.com/maps?f=d&source=s_d&saddr=Milwaukee,+WI&daddr=Albuquerque,+NM&hl=en&geocode=Fba4kAIdVqfC-innR4tX1wIFiDGEe0G1IhlfRA%3BFctYFwId_6Gk-Sl7gwnT3QoihzH99tm4zvjTwA&mra=ls&sll=37.0625,-95.677068&sspn=40.460237,79.013672&ie=UTF8&z=6 and then
              https://personal.paypal.com/cgi-bin/marketingweb?cmd=_render-content&content_ID=marketing_us/pay_online&nav=0.1 and then
              and http://rtl.lu/home, http://news.rtl.lu/news/international/74127.html#comments, and http://ipaper.rtl.lu/display/DisplayShopping.188_48.20-48.
            </p>
          </div>
        </body>
      </html>
    }
    target_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p id="explanation">
              The following is a collection of even more links you would come across.
            </p>
            <p>
              The following links should be linkified:
              <a href="http://www.youtube.com/watch?v=_OBlgSz8sSM">http://www.youtube.com/watch?v=_OBlgSz8sSM</a> and
              <a href="http://maps.google.com/maps?f=d&source=s_d&saddr=Milwaukee,+WI&daddr=Albuquerque,+NM&hl=en&geocode=Fba4kAIdVqfC-innR4tX1wIFiDGEe0G1IhlfRA%3BFctYFwId_6Gk-Sl7gwnT3QoihzH99tm4zvjTwA&mra=ls&sll=37.0625,-95.677068&sspn=40.460237,79.013672&ie=UTF8&z=6">http://maps.google.com/maps?f=d&source=s_d&saddr=Milwaukee,+WI&daddr=Albuquerque,+NM&hl=en&geocode=Fba4kAIdVqfC-innR4tX1wIFiDGEe0G1IhlfRA%3BFctYFwId_6Gk-Sl7gwnT3QoihzH99tm4zvjTwA&mra=ls&sll=37.0625,-95.677068&sspn=40.460237,79.013672&ie=UTF8&z=6</a> and then
              <a href="https://personal.paypal.com/cgi-bin/marketingweb?cmd=_render-content&content_ID=marketing_us/pay_online&nav=0.1">https://personal.paypal.com/cgi-bin/marketingweb?cmd=_render-content&content_ID=marketing_us/pay_online&nav=0.1</a> and then
              and <a href="http://rtl.lu/home">http://rtl.lu/home</a>, <a href="http://news.rtl.lu/news/international/74127.html#comments">http://news.rtl.lu/news/international/74127.html#comments</a>, and <a href="http://ipaper.rtl.lu/display/DisplayShopping.188_48.20-48">http://ipaper.rtl.lu/display/DisplayShopping.188_48.20-48</a>.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


  def test_false_positives
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              Nothing in this paragraph should be linkified, including index.html or
              /foo/bar or /foo/bar.html or net gov com.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal before_html, after_html
  end


  def test_comments_not_linkified
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <!-- Nothing in HTML comments should be linkified, including foo.html or
                 google.com or http://www.google.com or example.com/foo. -->
            <p>
              Alaska has the population of a small city.  Just sayin'.
            </p>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal before_html, after_html
  end


end
