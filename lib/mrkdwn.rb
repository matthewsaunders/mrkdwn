require_relative 'mrkdwn/parser'
require_relative 'mrkdwn/renderer'

module Mrkdwn
  def self.toHtml(markdown)
    tokens = Mrkdwn::Parser.parse(markdown)
    html = Mrkdwn::Renderer.render(tokens)
    html
  end
end
