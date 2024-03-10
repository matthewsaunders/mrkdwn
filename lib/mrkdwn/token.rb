export type Token = (
  Tokens.Space
| Tokens.Code
| Tokens.Heading
| Tokens.Table
| Tokens.Hr
| Tokens.Blockquote
| Tokens.List
| Tokens.ListItem
| Tokens.Paragraph
| Tokens.HTML
| Tokens.Text
| Tokens.Def
| Tokens.Escape
| Tokens.Tag
| Tokens.Image
| Tokens.Link
| Tokens.Strong
| Tokens.Em
| Tokens.Codespan
| Tokens.Br
| Tokens.Del
| Tokens.Generic);

module Mrkdwn
  const TOKENS = {

  }

  class Token
    def initialize(type:, raw:)
      @type = type
      @raw = raw
    end
  end
end
