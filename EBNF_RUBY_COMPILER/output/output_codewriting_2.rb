require 'pp'
require_relative 'lexer'
#require_relative 'ast'


TOKEN_DEF={
  :token_1	=> /_/,
  :token_2	=> /\'/,
  :token_3	=> /\"/,
  :token_4	=> /\|/,
  :token_5	=> /\,/,
  :token_6	=> /\[/,
  :token_7	=> /\]/,
  :token_8	=> /\{/,
  :token_9	=> /\}/,
  :token_10	=> /\(/,
  :token_11	=> /\)/,
  :token_12	=> /\=/,
  :token_13	=> /\;/,
  
  :identifier	=> /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer	=> /[0-9]+/,
  :reste        => /./
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
      puts "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos}"
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
    parsegrammar #this is the last uncalled rule in the ast, first rule could be another
    puts "end"
  end

  #=======Specific to language=========

  def parsecharacter
    tmpStream2=@lexer.stream.clone
    begin
      parseletter

    rescue
      set_Stream(tmpStream2)
    else
      return
    end
    tmpStream2=@lexer.stream.clone
    begin
      parsedigit

    rescue
      set_Stream(tmpStream2)
    else
      return
    end
    tmpStream2=@lexer.stream.clone
    begin
      parsesymbol

    rescue
      set_Stream(tmpStream2)
    else
      return
    end

    expect :token_1

  end

  def parsealphaNum
    tmpStream2=@lexer.stream.clone
    begin
      parseletter

    rescue
      set_Stream(tmpStream2)
    else
      return
    end
    tmpStream2=@lexer.stream.clone
    begin
      parsedigit

    rescue
      set_Stream(tmpStream2)
    else
      return
    end

    expect :token_1

  end

  def parseidentifier
    parseletter
    continue=true
    while continue
      tmpStream3=@lexer.stream.clone
      begin
        parsealphaNum

      rescue
        set_Stream(tmpStream3)
        continue=false
      end
    end

  end

  def parseterminal
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_2

      expect :token_2
      puts "type 2"
      parsecharacter
      continue_3 = false
      if showNext.kind!= :token_2
        continue_3 = true
      end

      while continue_3
        parsecharacter
        if showNext.kind== :token_2
          continue_3 = false
        end
      end

      expect :token_2
      return 
    end
    expect :token_3
    puts "type 3"
    parsecharacter
    continue_2 = false
    if showNext.kind!= :token_3
      continue_2 = true
    end

    while continue_2
      parsecharacter
      if showNext.kind== :token_3
        continue_2 = false
      end
    end

    expect :token_3

  end

  def parselhs
    parseidentifier

  end

  def parserhs checkNeeded = true
    
    tmpStream2=@lexer.stream.clone
    begin
      parseidentifier
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return
    end
    tmpStream2=@lexer.stream.clone
    begin
      parseterminal
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        raise ""
      end

    rescue
      
      set_Stream(tmpStream2)
    else
      return
    end
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_6

      expect :token_6
      parserhs

      expect :token_7
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return 
      end
    end
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_8

      expect :token_8
      parserhs

      expect :token_9
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return 
      end
    end
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_10

      expect :token_10
      parserhs

      expect :token_11
      if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
        set_Stream(tmpStream2)
      else
        return 
      end
    end
    tmpStream2=@lexer.stream.clone
    begin
      
      parserhs false
      expect :token_4
      parserhs
      #if ( showNext.kind == :token_4|| showNext.kind == :token_5) && checkNeeded
      #  raise ""
      #end

    rescue
      set_Stream(tmpStream2)
    else
      return
    end
    parserhs false

    expect :token_5
    parserhs

  end

  def parserule
    parselhs

    expect :token_12
    parserhs

    expect :token_13

  end

  def parsegrammar
    continue=true
    while continue
      tmpStream3=@lexer.stream.clone
      begin
        parserule

      rescue
        set_Stream(tmpStream3)
        continue=false
      end
    end

  end



  #====== Missing Rules ======

  def parseletter
    value = (expect :identifier).value
  end

  def parsedigit
    (expect :integer)
  end

  def parsesymbol
    if [:token_2,:token_3,:token_4,:token_5,:token_6,:token_7,:token_8,:token_9,:token_10,:token_11,:token_12,:token_13].include?(showNext.kind)
      acceptIt.value
    else
      (expect :reste).value
    end
  end



end

