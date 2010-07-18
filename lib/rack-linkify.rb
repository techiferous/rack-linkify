require 'rack-plastic'

module Rack
  class Linkify < Plastic
 
    def change_nokogiri_doc(doc)
      find_candidate_links(doc)
      doc
    end
    
    def change_html_string(html)
      linkify(html)
    end

    private
    
    def find_candidate_links(doc)
      doc.at_css("body").traverse do |node|
        if node.text?
          update_text(node, mark_links(node.content))
        end
      end
    end
    
    def linkify(html)
      html.gsub!(/beginninganchor1(?!http)/, 'beginninganchor1http://')
      html.gsub!('beginninganchor1', '<a href="')
      html.gsub!('beginninganchor2', '">')
      html.gsub!('endinganchor', '</a>')
      html
    end
 
    def mark_links(text)
 
      new_text = text
      
      # A pattern-matching algorithm that would correctly detect URLs 100% of the time
      # would be prohibitively complex. For example, if a URL in a sentence is followed
      # by a comma, like http://www.google.com, we would want to match the URL but
      # skip the comma. However, commas are allowed in URLs. So there are a lot
      # of edge cases that make a complete solution very complex.
      #
      # The following strategy has the benefits of being relatively straightforword
      # to implement as well as having high accuracy. Text is scanned for top-level
      # domains, and if one is found it is assumed to be a URL.
 
      common_gtlds = "com|net|org|edu|gov|info|mil|name|mobi|biz"
 
      new_text.gsub!(/\b
                      (\S+\.(#{common_gtlds}|[a-z]{2})\S*) # match words that contain common
                                                           # top-level domains or country codes
                                                           # 
                      (\.|\?|!|:|,|\))*                    # if the URL ends in punctuation,
                                                           # assume the punction is grammatical
                                                           # and is not part of the URL
                                                           # 
                      \b/x,
        # We mark the text with phrases like "beginninganchor1". That's because it's
        # much easier to replace these strings later with anchor tags rather than work within
        # Nokogiri's document structure to add a new node in the middle of the text.
       'beginninganchor1\0beginninganchor2\0\3endinganchor')
 
      # text that looks like @foo can become a twitter link
      if options[:twitter]
        new_text.gsub!(/(^|\s)(@(\w+))(\.|\?|!|:|,\))*\b/,
         '\1beginninganchor1http://twitter.com/\3beginninganchor2\2endinganchor')
      end
 
      new_text

    end
 
  end
end
