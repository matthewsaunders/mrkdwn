require 'mrkdwn/parser'

describe Mrkdwn::Parser do
  describe '#parse' do
    describe 'text' do
      it 'is parsed' do
        input = <<~MARKDOWN
        sample text
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'sample text' }
            ]
          }
        ])
      end

      it 'parses multiline text as one block' do
        input = <<~MARKDOWN
        sample text
        on multiple lines
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'sample text' },
              { type: 'NEW_LINE' },
              { type: 'RAW_TEXT', text: 'on multiple lines' },
            ]
          }
        ])
      end

      it 'avoids parsing multiline text with trailing heading' do
        input = <<~MARKDOWN
        sample text
        # on multiple lines
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'sample text' },
            ]
          },
          {
            type: 'HEADING',
            depth: 1,
            tokens: [
              { type: 'RAW_TEXT', text: 'on multiple lines' }
            ]
          }
        ])
      end

      it 'parses multiple text blocks with empty lines in between' do
        input = <<~MARKDOWN
        sample text


        some more text
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'sample text' },
            ]
          },
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'some more text' },
            ]
          },
        ])
      end

      it 'parses open inline modifiers as text' do
        input = <<~MARKDOWN
        *text
        MARKDOWN


        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: '*text' },
            ]
          },
        ])
      end

      it 'parses links within text' do
        input = <<~MARKDOWN
        left [GITHUB](https://github.com/) right
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'left' },
              {
                type: 'A',
                href: 'https://github.com/',
                tokens: [
                  { type: 'RAW_TEXT', text: 'GITHUB' }
                ]
              },
              { type: 'RAW_TEXT', text: 'right' },
            ]
          }
        ])
      end
    end

    describe 'strong' do
      it 'is parsed' do
        input = <<~MARKDOWN
        **bold text**
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'STRONG',
            tokens: [
              { type: 'RAW_TEXT', text: 'bold text' }
            ]
          }
        ])
      end
    end

    describe 'em' do
      it 'is parsed' do
        input = <<~MARKDOWN
        *emphasised text*
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'EM',
            tokens: [
              { type: 'RAW_TEXT', text: 'emphasised text' }
            ]
          }
        ])
      end

      it 'is parsed when part of a heading' do
        input = <<~MARKDOWN
        ## emphasised *text*
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'HEADING',
            depth: 2,
            tokens: [
              { type: 'RAW_TEXT', text: 'emphasised' },
              {
                type: 'EM',
                tokens: [
                  { type: 'RAW_TEXT', text: 'text' }
                ]
              }
            ]
          }
        ])
      end
    end

    describe 'del' do
      it 'is parsed' do
        input = <<~MARKDOWN
        ~~stricken text~~
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'DEL',
            tokens: [
              { type: 'RAW_TEXT', text: 'stricken text' }
            ]
          }
        ])
      end
    end

    describe 'code' do
      it 'is parsed' do
        input = <<~MARKDOWN
        `code text`
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'CODE',
            tokens: [
              { type: 'RAW_TEXT', text: 'code text' }
            ]
          }
        ])
      end
    end

    describe 'heading' do
      it 'is parsed' do
        # input = '## sample heading'
        input = <<~MARKDOWN
        # sample heading
        ###### another heading
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'HEADING',
            depth: 1,
            tokens: [
              { type: 'RAW_TEXT', text: 'sample heading' }
            ]
          },
          {
            type: 'HEADING',
            depth: 6,
            tokens: [
              { type: 'RAW_TEXT', text: 'another heading' }
            ]
          },
        ])
      end
    end

    describe 'anchor' do
      it 'is parsed' do
        input = <<~MARKDOWN
        [GITHUB](https://github.com/)
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'A',
            href: 'https://github.com/',
            tokens: [
              { type: 'RAW_TEXT', text: 'GITHUB' }
            ]
          }
        ])
      end
    end

    describe 'mixed content' do
      it 'handles a link within text' do
        input = <<~MARKDOWN
        This is sample markdown for the [Mailchimp](https://www.mailchimp.com) homework assignment.
        MARKDOWN

        output = Mrkdwn::Parser.parse(input)

        expect(output).to eq([
          {
            type: 'TEXT',
            tokens: [
              { type: 'RAW_TEXT', text: 'This is sample markdown for the' },
              {
                type: 'A',
                href: 'https://www.mailchimp.com',
                tokens: [
                  { type: 'RAW_TEXT', text: 'Mailchimp' }
                ]
              },
              { type: 'RAW_TEXT', text: 'homework assignment.' }
            ]
          }
        ])
      end
    end
  end
end
