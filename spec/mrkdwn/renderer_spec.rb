require 'mrkdwn/renderer'

describe Mrkdwn::Renderer do
  describe '#render' do
    describe 'given heading' do
      it 'renders' do
        input = [{
          type: 'HEADING',
          depth: 1,
          tokens: [
            { type: 'RAW_TEXT', text: 'sample heading' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<h1>sample heading</h1>\n")
      end
    end

    describe 'given strong' do
      it 'renders' do
        input = [{
          type: 'STRONG',
          tokens: [
            { type: 'RAW_TEXT', text: 'bold text' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<strong>bold text</strong>\n")
      end
    end

    describe 'given em' do
      it 'renders' do
        input = [{
          type: 'EM',
          tokens: [
            { type: 'RAW_TEXT', text: 'emphasised text' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<em>emphasised text</em>\n")
      end
    end

    describe 'given del' do
      it 'renders' do
        input = [{
          type: 'DEL',
          tokens: [
            { type: 'RAW_TEXT', text: 'stricken text' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<del>stricken text</del>\n")
      end
    end

    describe 'given code' do
      it 'renders' do
        input = [{
          type: 'CODE',
          tokens: [
            { type: 'RAW_TEXT', text: 'code text' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<code>code text</code>\n")
      end
    end

    describe 'given anchor' do
      it 'renders' do
        input = [{
          type: 'A',
          href: 'https://github.com/',
          tokens: [
            { type: 'RAW_TEXT', text: 'GITHUB' }
          ]
        }]

        output = Mrkdwn::Renderer.render(input)

        expect(output).to eq("<a href=\"https://github.com/\">GITHUB</a>\n")
      end
    end
  end
end
