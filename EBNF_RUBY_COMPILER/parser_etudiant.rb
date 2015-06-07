require 'pp'
require_relative 'lexer'
require_relative 'ast'


TOKEN_DEF={
  :egeg		=> /\=\=/,
  :def 		=> /\=/,
  :concat	=> /\,/,
  :term		=> /\;/,
  :alternaltern => /\|\|/,
  :altern	=> /\|/,
  :loption	=> /\[/,
  :roption	=> /\]/,
  :lrepetition	=> /\{/,
  :rrepetition  => /\}/,
  :lgrouping	=> /\(/,
  :rgrouping    => /\)/,
  :terminalstr2 => /\"/,
  :terminalstr1 => /\'/,
  :lcomment     => /\(\*/,#not currently in use
  :rcomment     => /\*\)/,
  :specialseq   => /\?/,
  :exception    => /\-/,
  :integer	=> /[0-9]+/,
  :letterLit    => /[a-zA-Z]/,
  :under	=> /\_/,
  :point	=> /\./,
  :eginf	=> /\<\=/,
  :egsup	=> /\>\=/,
  :inf		=> /\</,
  :sup		=> /\>/,
  :andand	=> /\&\&/,
  :and		=> /\&/,
  :etoile	=> /\*/,
  :autre	=> /./

  
}

class Parser

  attr_accessor :lexer

  def initialize
    @lexer=Lexer.new(TOKEN_DEF)
    @dataFic = File.open("data_stream.data","w")
    @data=@dataFic
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    @length = @lexer.stream.length
    output = parseModule()
    @dataFic.close
    output
  end

  def expect token_kind
    @data.write "#{@length - @lexer.stream.length}\n" #data recuperation on parser efficiency
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      # no puts as it would flood the console
      raise "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos} \n\tparsing error"
    end
    return next_tok    
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @data.write "#{@length - @lexer.stream.length}\n" #data recuperation on parser efficiency
    @lexer.get_next
  end
  
  def set_Stream newStream
    @lexer.set_Stream(newStream)
  end

  #=========== parse method relative to the grammar ========
  def parseModule
    puts "parseModule"
    modul = Modul.new
    modul.grammar=parseGrammar()
    puts "ending parsing files"
    return modul
  end

  def parseGrammar
    grammar = Grammar.new
    while showNext!=nil
      grammar.rule << parseRule()
    end
    return grammar
  end

  def parseRule
    puts "Parse Rule"
    rule = Rule.new
    rule.lhs = parseLhs()
    expect :def
    rule.rhs = parseRhs
    puts "============================="
    
    expect :term
    return rule
  end

  def parseLhs
     lhs = Lhs.new
     lhs.ident = parseIdentifier()
     return lhs
  end

  def parseRhs rhsKind=true
    #puts "Parsing Rhs"
    rhs = Rhs.new
    tmpStream = @lexer.stream.clone

    # Identifier
    if showNext.kind==:letterLit
      rhs.ident=parseIdentifier()
      if [:altern,:concat].include?(showNext.kind) && rhsKind 
        set_Stream(tmpStream)
        tmpStream = tmpStream.clone
      else
        return rhs
      end
    end

    # Terminal
    rhs = Rhs.new
    if [:terminalstr1,:terminalstr2].include?(showNext.kind)
      
      rhs.terminal = parseTerminal()
      if [:altern,:concat].include?(showNext.kind) && rhsKind 
        set_Stream(tmpStream)
        tmpStream = tmpStream.clone
      else
        return rhs
      end
    end

    # [rhs]
    rhs = Rhs.new
    if showNext.kind==:loption
      expect :loption
      rhs.optRhs=parseRhs
      expect :roption
      if [:altern,:concat].include?(showNext.kind) && rhsKind 
        set_Stream(tmpStream)
        tmpStream = tmpStream.clone
      else
        return rhs
      end
    end

    # {rhs}
    rhs = Rhs.new
    if showNext.kind==:lrepetition
      expect :lrepetition
      rhs.repRhs=parseRhs
      expect :rrepetition
      if [:altern,:concat].include?(showNext.kind) && rhsKind 
        set_Stream(tmpStream)
        tmpStream = tmpStream.clone
      else
        return rhs
      end
    end

    # (rhs)
    rhs = Rhs.new
    if showNext.kind==:lgrouping
      expect :lgrouping
      rhs.groupRhs=parseRhs
      expect :rgrouping
      if [:altern,:concat].include?(showNext.kind) && rhsKind 
        set_Stream(tmpStream)
        tmpStream = tmpStream.clone
      else
        return rhs
      end
    end

    # rhs | rhs
    rhs = Rhs.new 
    begin
      rhs.altRhs << parseRhs(false) 
      expect :altern
      rhs.altRhs << parseRhs
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      return rhs
    end

    # rhs , rhs
    rhs = Rhs.new
    rhs.concRhs << parseRhs(false)
    expect :concat
    rhs.concRhs << parseRhs
    return rhs
  end

  def parseTerminal
    #puts "Parsing Terminal"
    terminal=Terminal.new
    if showNext.kind == :terminalstr1
      expect :terminalstr1
      terminal.character << parseCharacter()
      while showNext.kind != :terminalstr1
        terminal.character << parseCharacter()    
      end
      expect :terminalstr1
    elsif showNext.kind == :terminalstr2
        expect :terminalstr2
        terminal.character << parseCharacter()
        while showNext.kind != :terminalstr2
          terminal.character << parseCharacter()
        end
        expect :terminalstr2
    else
      puts "expecting #{:terminalstr2} or #{:terminalstr1}. Got #{showNext.kind} at #{showNext.pos}"
      raise "parsing error"
    end   
    return terminal  
  end 

  def parseIdentifier
    #puts "Parsing ident"
    ident = Identifier.new
    ident.letter = parseLet
    continue = true
    while [:letterLit,:integer,:under].include?(showNext.kind)
        ident.alphaNum << parseAlphaNum()
    end 
    return ident
  end

  def parseAlphaNum
    alphaNum = AlphaNum.new
    if showNext.kind == :letterLit
      alphaNum.letter = parseLet
      return alphaNum
    end

    
    if showNext.kind == :integer
      alphaNum.digit = parseDig
      return alphaNum
    end

    alphaNum.under = (expect :under).value
    return alphaNum
  end

  def parseCharacter 
    character = Character.new
    if showNext.kind == :letterLit
      character.letter = parseLet
      return character
    end

    if showNext.kind == :integer
      character.digit = parseDig
      return character
    end

    if ![:letterLit,:integer,:under].include?(showNext.kind)
      character.symbol = parseSym
      return character
    end 
    character.under = (expect :under).value
    return character
  end  

  def parseLet
    
    letter = Letter.new
    letter.letter = (expect :letterLit).value
    return letter
  end

  def parseDig
    digit = Digit.new
    digit.digit = (expect :integer).value
    return digit
  end

  def parseSym
    
    symbol = Symbol_.new
    if ![:letterLit,:integer,:under].include?(showNext.kind)
    	symbol.symbol = acceptIt.value
    else
      raise "parsing error expecting symbol got #{showNext.kind} at #{showNext.pos}"
    end
    return symbol
  end
end
