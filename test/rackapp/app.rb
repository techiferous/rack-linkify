class App

  def call(env)
    response = Rack::Response.new
    response['Content-Type'] = 'text/html'
    response.write front_page
    response.finish
  end
  
  def front_page
    %Q{
      <!DOCTYPE html
      PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
        <head>
          <title>Testing Rack::Linkify</title>
        </head>
        <body>
          <div id="container">
            <h1>Testing Rack::Linkify</h1>
            <h2>How To Test</h2>
            <p>
              This gem comes with the expected automated unit tests that
              you can run by simply typing 'rake test'.
            </p>
            <p>
              This page serves as an integration test of sorts where you can
              actually <em>see</em> the results of Rack::Linkify in your
              browser.
            </p>
            <h2>Tests</h2>
            <p>
              This is a test of links in free-flowing text. <br />
              Test a typical URL http://www.google.com <br />
              Test a URL followed by a period http://www.google.com. <br />
              Test a URL without the http www.google.com <br />
              Test a URL without http and ending in a period www.google.com. <br />
              Test a URL without www and followed by a comma google.com, <br />
              Test a URL followed by a bang google.com! <br />
              Test a URL followed by a hook google.com? <br />
              Test a URL followed by an interrobang google.com?! <br />
              Test another URL coderack.org <br />
              Test a URL with a path google.com/foobar <br />
              Test a longer URL google.com/foobar/index.html. <br />
              Test a URL followed by a parenthesis google.com) <br />
              Test a URL followed by a parenthesis and comma google.com), <br />
              Test atypical gTLDs http://www.something.info, and http://del.icio.us <br />
              Test more atypical gTLDs http://bit.ly/n0og http://www.wikio.co.uk <br />
            </p>
            <p>
              Here are some more links:
              <pre>
                http://www.google.com
                http://www.google.co.uk
                www.google.com
                google.com
                http://localhost:3000/houses
                http://oreilly.com/ruby/excerpts/ruby-learning-rails/ruby-guide-regular-expressions.html
                http://www.regular-expressions.info/freespacing.html
                http://www.perlmonks.org/?node_id=518444
                localhost:3000/houses
                oreilly.com/ruby/excerpts/ruby-learning-rails/ruby-guide-regular-expressions.html
                www.regular-expressions.info/freespacing.html
                www.perlmonks.org/?node_id=518444
                http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=375+Harvard+St,+Cambridge,+MA+02138&sll=42.398774,-71.117184&sspn=0.008097,0.019205&ie=UTF8&ll=42.372781,-71.112099&spn=0.008101,0.019205&z=16&iwloc=A
              </pre>
            <p>
              here is a potential twitter address @techiferous <br />
              here it is with punctuation @techiferous. <br />
              will this work? @coderack?!?! <br />
              and how about this? @techiferous) <br />
            </p>
          </div>
        </body>
      </html>
    }
  end
  
end
