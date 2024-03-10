require './lib/mrkdwn'
require 'debug'

describe Mrkdwn do
  describe "#toHtml" do
    it "converts sample input #1" do
      markdown = <<~MARKDOWN
      # Sample Document

      Hello!

      This is sample markdown for the [Mailchimp](https://www.mailchimp.com) homework assignment.
      MARKDOWN

      expectedHtml = <<~HTML
      <h1>Sample Document</h1>

      <p>Hello!</p>

      <p>This is sample markdown for the <a href="https://www.mailchimp.com">Mailchimp</a> homework assignment.</p>
      HTML

      expect(Mrkdwn.toHtml(markdown)).to eq(expectedHtml)
    end

    it "converts sample input #2" do
      markdown = <<~MARKDOWN
      # Header one

      Hello there

      How are you?
      What's going on?

      ## Another Header

      This is a paragraph [with an inline link](http://google.com). Neat, eh?

      ## This is a header [with a link](http://yahoo.com)
      MARKDOWN

      expectedHtml = <<~HTML
      <h1>Header one</h1>

      <p>Hello there</p>

      <p>How are you?
      What's going on?</p>

      <h2>Another Header</h2>

      <p>This is a paragraph <a href="http://google.com">with an inline link</a>. Neat, eh?</p>

      <h2>This is a header <a href="http://yahoo.com">with a link</a></h2>
      HTML

      expect(Mrkdwn.toHtml(markdown)).to eq(expectedHtml)
    end
  end
end
