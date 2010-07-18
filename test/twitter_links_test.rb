require 'test/test_helper'

class TwitterLinksTest < Test::Unit::TestCase

  def test_twitter_links
    before_html = %Q{
      <html>
        <head><title>Testing Rack::Linkify</title></head>
        <body>
          <div id="container">
            <p>
              This test should linkify links like @foo and @bar if twitter is set to true.
            </p>
            The following should be linkified:
            <ul>
              <li>@foo</li>
              <li>@bar</li>
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
              This test should linkify links like <a href="http://twitter.com/foo">@foo</a> and <a href="http://twitter.com/bar">@bar</a> if twitter is set to true.
            </p>
            The following should be linkified:
            <ul>
              <li><a href="http://twitter.com/foo">@foo</a></li>
              <li><a href="http://twitter.com/bar">@bar</a></li>
            </ul>
          </div>
        </body>
      </html>
    }
    after_html = linkify_this_html(before_html)
    assert_html_equal target_html, after_html
  end


end
