require 'pp'
require_relative 'lexer'
require_relative 'output_astwriting'


TOKEN_DEF={
  :token_1	=> /_/,
  :token_2	=> /\'/,
  :token_3	=> /\"/,
  :token_4	=> /\|/,
  :token_5	=> /\,/,
  :token_6	=> /\[/,
  :token_7	=> /\]/,
  :token_8	=> /\£\£\£/,
  :token_9	=> /\{/,
  :token_10	=> /\}/,
  :token_11	=> /\(/,
  :token_12	=> /\)/,
  :token_13	=> /\=/,
  :token_14	=> /\;/,
  

# !!!! auto writting of the next kind of token, to be deleted or put in missing rule(s)
  :identifier	=> /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer	=> /[0-9]+/#,
  #:reste	=> /./
}

class Parser

  attr_accessor :lexer

  def initialize
    @lexer=Lexer.new(TOKEN_DEF)
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseModule()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      @last_error = "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos}"
      raise "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos} \n\tparsing error"
    end
    return next_tok    
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @lexer.get_next
  end

  def add_first token #deprecated method
    @lexer.add_first(token)
  end

  def get_Stream #deprecated method
    @lexer.get_Stream
  end
  
  def set_Stream newStream
    @lexer.set_Stream(newStream)
  end
  
  #======= First Call ================= Write fisrt rule to be applied, in method parseModule
  
  def parseModule
    puts "start of parsing"
    ast = parsegrammar #this is the last uncalled rule in the ast, first rule could be another
    puts "end"
    if get_Stream!=[] #printing of the last error if stream not finish due to use of begin and rescue we can not crash but still the file to be parse is not write correctly
       puts @last_error
       exit
    end 
    ast
  end

  #=======Specific to language=========

  def parsecharacter
    character = CHARACTER.new
    tmpStream2=@lexer.stream.clone
    begin
      character.agletter_1 = parseletter

    rescue
      set_Stream(tmpStream2)
    else
      return character
    end
    character = CHARACTER.new
    tmpStream2=@lexer.stream.clone
    begin
      character.agdigit_1 = parsedigit

    rescue
      set_Stream(tmpStream2)
    else
      return character
    end
    character = CHARACTER.new
    tmpStream2=@lexer.stream.clone
    begin
      character.agsymbol_1 = parsesymbol

    rescue
      set_Stream(tmpStream2)
    else
      return character
    end
    character = CHARACTER.new

    expect :token_1
    character

  end

  def parsealphaNum
    alphanum = ALPHANUM.new
    tmpStream2=@lexer.stream.clone
    begin
      alphanum.agletter_1 = parseletter

    rescue
      set_Stream(tmpStream2)
    else
      return alphanum
    end
    alphanum = ALPHANUM.new
    tmpStream2=@lexer.stream.clone
    begin
      alphanum.agdigit_1 = parsedigit

    rescue
      set_Stream(tmpStream2)
    else
      return alphanum
    end
    alphanum = ALPHANUM.new

    expect :token_1
    alphanum

  end

  def parseidentifier
    identifier = IDENTIFIER.new
    identifier.letter_1 = parseletter
    continue=true
    while continue
      tmpidentifier3=identifier.clone
      tmpStream3=@lexer.stream.clone
      begin
        identifier.ralphanum_1 << parsealphaNum

      rescue
        set_Stream(tmpStream3)
        identifier=tmpidentifier3
        continue=false
      end
    end
    identifier

  end

  def parseterminal
    terminal = TERMINAL.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_2

      expect :token_2
      terminal.agcharacter_1 = parsecharacter
      continue_3 = false
      if showNext.kind!= :token_2
        continue_3 = true
      end

      while continue_3
        terminal.agrcharacter_1 << parsecharacter
        if showNext.kind== :token_2
          continue_3 = false
        end
      end

      expect :token_2
      return terminal
    end
    terminal = TERMINAL.new

    expect :token_3
    terminal.agcharacter_2 = parsecharacter
    continue_2 = false
    if showNext.kind!= :token_3
      continue_2 = true
    end

    while continue_2
      terminal.agrcharacter_2 << parsecharacter
      if showNext.kind== :token_3
        continue_2 = false
      end
    end

    expect :token_3
    terminal

  end

  def parselhs
    lhs = LHS.new
    lhs.identifier_1 = parseidentifier
    lhs

  end

  def parserhs checkNeeded = true
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    begin
      rhs.agidentifier_1 = parseidentifier
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return rhs
    end
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    begin
      rhs.agterminal_1 = parseterminal
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return rhs
    end
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_6

      expect :token_6
      rhs.agrhs_1 = parserhs

      expect :token_7

      expect :token_8
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return rhs 
      end
    end
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_9

      expect :token_9
      rhs.agrhs_2 = parserhs

      expect :token_10
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return rhs 
      end
    end
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_11

      expect :token_11
      rhs.agrhs_3 = parserhs

      expect :token_12
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return rhs 
      end
    end
    rhs = RHS.new
    tmpStream2=@lexer.stream.clone
    begin
      rhs.agrhs_4 = parserhs false

      expect :token_4
      rhs.agrhs_5 = parserhs
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return rhs
    end
    rhs = RHS.new
    rhs.agrhs_6 = parserhs false

    expect :token_5
    rhs.agrhs_7 = parserhs
    rhs

  end

  def parserule
    rule = RULE.new
    rule.lhs_1 = parselhs

    expect :token_13
    rule.rhs_1 = parserhs

    expect :token_14
    rule

  end

  def parsegrammar
    grammar = GRAMMAR.new
    continue=true
    while continue
      tmpgrammar3=grammar.clone
      tmpStream3=@lexer.stream.clone
      begin
        grammar.rrule_1 << parserule

      rescue
        set_Stream(tmpStream3)
        grammar=tmpgrammar3
        continue=false
      end
    end
    grammar

  end



  #====== Missing Rules ======

  def parseletter
    
  end

  def parsedigit
    
  end

  def parsesymbol
    
  end



end

