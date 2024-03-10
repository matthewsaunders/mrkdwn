module Mrkdwn
  HEADING_CHAR = "#"
  EM_CHAR = "*"
  STRONG_CHAR = "**"
  DEL_CHAR = '~'
  CODE_CHAR = '`'
  LBRACKET_CHAR = '['
  RBRACKET_CHAR = ']'
  LPARAN_CHAR = '('
  RPARAN_CHAR = ')'

  SPACE = " "
  NEWLINE_CHAR = "\n"
  TAB_CHAR = "\t"
  RETURN_CHAR = "\r"
  WHITESPACE_CHARS = [SPACE, NEWLINE_CHAR, TAB_CHAR, RETURN_CHAR]

  INLINE_SPECIAL_CHARS = [
    EM_CHAR,
    STRONG_CHAR,
    DEL_CHAR,
    CODE_CHAR,
    LBRACKET_CHAR
  ]

  SPECIAL_CHARS = [
    HEADING_CHAR,
    EM_CHAR,
    STRONG_CHAR,
    NEWLINE_CHAR,
    CODE_CHAR,
  ]

  # A class for parse markdown into an array of tokens that represent a lexed and
  # parsed version of the markdown document. Accessed by calling:
  #
  # tokens = Mrkdwn::Parser.parse(markdown)
  #
  class Parser
    def initialize(input, parsing_inline)
      @input = input.split('')
      @position = 0
      @next_position = 1
      @char = @input[0]
      @tokens = []
      @parsing_inline = parsing_inline
    end

    # Method for calling in a static context
    def self.parse(markdown, parsing_inline = false)
      p = Parser.new(markdown, parsing_inline)
      p.parse
    end

    def peek_char
      return nil if @next_position >= @input.length

      @input[@next_position]
    end

    # TODO: Is this used?
    def peek_char_n_ahead(n)
      peek_position = @position + n
      return nil if peek_position >= @input.length

      @input[peek_position]
    end

    def read_char
      @char = self.peek_char
      @position = @next_position
      @next_position += 1
    end

    def skip_white_space
      while @char == SPACE || @char == TAB_CHAR || @char == RETURN_CHAR || @char == NEWLINE_CHAR
        self.read_char
      end
    end

    def at_eof?
      @position >= @input.length
    end

    def next_at_eof?
      @next_position >= @input.length
    end

    def parse_line
      text = ''

      while @char != NEWLINE_CHAR && !self.at_eof?
        text += @char
        self.read_char
      end

      text
    end

    # Read ahead from the current position and see if any chars exist besides
    # whitespace chars before newline or EOF. Do not actually move @position.
    def is_empty_line?
      pos = @position

      while pos < @input.length && pos != NEWLINE_CHAR
        return false if WHITESPACE_CHARS.include?(@input[pos])

        pos += 1
      end

      # We either reached EOL or EOF, so line must be just whitespace
      true
    end

    def at_end_of_line?
      @char == NEWLINE_CHAR || @char == nil || self.at_eof?
    end

    def reset_to_position(position)
      @position = position
      @next_position = @position + 1
      @char = @input[@position]
    end

    def parse_heading
      start_position = @position
      depth = 0

      while @char == '#'
        depth += 1
        self.read_char
      end

      text = self.parse_line

      { type: 'HEADING', depth: depth, tokens: Mrkdwn::Parser.parse(text, true) }
    end

    def parse_inline_exp_single_char(type, special_char)
      orig_position = @position
      text = ''

      # skip opening special chars (i.e. '*')
      self.read_char

      next_char = self.peek_char

      while @char != special_char && next_char != special_char && !self.at_end_of_line?
        text += @char
        self.read_char
      end

      # Forget we tried to parse del, rewind and parse text
      if self.at_end_of_line?
        self.reset_to_position(orig_position)
        return self.parse_text
      end

      { type: type, tokens: Mrkdwn::Parser.parse(text, true) }
    end

    def parse_inline_exp_double_char(type, special_char)
      orig_position = @position
      text = ''

      # skip opening two special chars (i.e. '**')
      self.read_char
      self.read_char

      next_char = self.peek_char

      while @char != special_char && next_char != special_char && !self.at_end_of_line?
        text += @char
        self.read_char
      end

      # Forget we tried to parse del, rewind and parse text
      if self.at_end_of_line?
        self.reset_to_position(orig_position)
        return self.parse_text
      end

      # read past the second closing special char
      self.read_char

      { type: type, tokens: Mrkdwn::Parser.parse(text, true) }
    end

    def parse_strong
      parse_inline_exp_double_char('STRONG', EM_CHAR)
    end

    def parse_em
      parse_inline_exp_single_char('EM', EM_CHAR)
    end

    def parse_del
      parse_inline_exp_double_char('DEL', DEL_CHAR)
    end

    def parse_code
      parse_inline_exp_single_char('CODE', CODE_CHAR)
    end

    def parse_anchor
      orig_position = @position
      text = ''
      href = ''

      # skip opening '['
      self.read_char

      # parse anchor text
      next_char = self.peek_char

      while @char != RBRACKET_CHAR && next_char != RBRACKET_CHAR && !self.at_end_of_line?
        text += @char
        self.read_char
      end

      # Forget we tried to parse anchor tag, rewind and parse text
      if self.at_end_of_line?
        self.reset_to_position(orig_position)
        return self.parse_text
      end

      self.read_char  # skip closing ']'

      if @char != LPARAN_CHAR
        self.reset_to_position(orig_position)
        return self.parse_text
      end

      self.read_char  # skip opening '('

      # parse anchor href
      next_char = self.peek_char

      while @char != RPARAN_CHAR && next_char != RPARAN_CHAR && !self.at_end_of_line?
        href += @char
        self.read_char
      end

      # Forget we tried to parse anchor tag, rewind and parse text
      if self.at_end_of_line?
        self.reset_to_position(orig_position)
        return self.parse_text
      end

      { type: 'A', tokens: Mrkdwn::Parser.parse(text, true), href: href }
    end

    def append_line_to_text(text, line)
      # Add a space between lines of text if text already exists
      spacer = text == '' ? '' : ' '

      # Check if we should introduce a new line token instead of a space
      next_char = self.peek_char

      text + spacer + line.strip
    end

    def parse_text
      done = false
      found_inline_char = false
      text = ''
      tokens = []

      # Loop through this section to read multiline text until EOF or a special
      # char indicating non text appears.
      #
      # Exit conditions:
      # - we reach EOF
      # - we reach end of line and next line is
      #   - empty / whitespace
      #   - contains a special character for non text content (i.e. heading)
      while !done
        line = ''
        spacer = ''

        while !self.at_end_of_line?
          # If we run into an inline special character, parse that
          if !found_inline_char && INLINE_SPECIAL_CHARS.include?(self.peek_char)
            found_inline_char = true
            tokens << { type: 'RAW_TEXT', text: self.append_line_to_text(text, line)  }

            # Reset to capture the rest of this text section for further parsing
            text = ''
            line = @char
          else
            line += @char
          end

          self.read_char
        end

        # Check for exit conditions
        if self.at_eof?
          done = true
        elsif @char == NEWLINE_CHAR
          # peek past new line
          next_char = self.peek_char

          # True if:
          # - the next line contains something other than text
          # - the next line is empty
          # - we are at EOF
          if SPECIAL_CHARS.include?(next_char) || self.is_empty_line? || self.next_at_eof?
            done = true
          else
            # We have hit a newline char, so cut the current line as raw text
            # and add a newline token.
            tokens << { type: 'RAW_TEXT', text: line }
            tokens << { type: 'NEW_LINE' }
            text = ''
            line = ''
            self.read_char
          end
        end

        text = self.append_line_to_text(text, line)
      end

      if @parsing_inline
        token = { type: 'RAW_TEXT', text: text }
        @tokens += tokens

        if found_inline_char
          # We are inline, so all tokens should be on the same flattened hierarchy
          @tokens += Mrkdwn::Parser.parse(text, true)
          return nil
        else
          token
        end
      else
        tokens += Mrkdwn::Parser.parse(text, true)
        { type: 'TEXT', tokens: tokens }
      end
    end

    def parse
      # Keep looping and walking the input until we hit the EOF
      while !self.at_eof?
        token = nil

        self.skip_white_space

        case @char
        when HEADING_CHAR
          token = self.parse_heading
        when EM_CHAR
          next_char = self.peek_char

          if next_char == EM_CHAR
            token = self.parse_strong
          else
            token = self.parse_em
          end
        when DEL_CHAR
          next_char = self.peek_char

          if next_char == DEL_CHAR
            token = self.parse_del
          else
            token = self.parse_text
          end
        when CODE_CHAR
          token = self.parse_code
        when LBRACKET_CHAR
          token = self.parse_anchor
        when SPACE, NEWLINE_CHAR, TAB_CHAR, RETURN_CHAR, nil
          # do nothing
        else
          # by default everything is just text
          token = self.parse_text
        end

        self.read_char

        @tokens << token unless token.nil?
      end

      @tokens
    end
  end
end
