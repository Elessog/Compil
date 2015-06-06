require 'pp'
require_relative 'lexer'
require_relative 'dictionnaire'
require_relative 'ast'

# A COMPLETER !
TOKEN_DEF={
  :letter 	=> /letterDef/,
  :digitStr	=> /digitDef/,
  :symbol	=> /symbolDef/,
  :reg		=> /reg/,
  :kw		=> /kw/,
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
  :lcomment     => /\(\*/,
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
  attr_accessor :dic
  attr_accessor :countPass

  def initialize
    @lexer=Lexer.new(TOKEN_DEF)
    @dic = Dictionnaire.new()
    @countPass=0
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseModule()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      #puts ""
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

  def add_first token
    @lexer.add_first(token)
  end

  def get_Stream
    @lexer.get_Stream
  end
  
  def set_Stream newStream
    @lexer.set_Stream(newStream)
  end

  #=========== parse method relative to the grammar ========
  def parseModule
    puts "parseModule"
    expect :letter
    parseLetter()
    puts "ending parsing letter"
    expect :digitStr
    parseDigit()
    puts "ending parsing digit"
    expect :symbol
    parseSymbol()
    puts "ending parsing Symbol"   
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
    rule = Rule.new
    rule.lhs = parseLhs()
    expect :def
    rule.rhs = parseRhs(1)
    #sleep(2)
    puts "============================="
    @countPass=0
    expect :term
    return rule
  end

  def parseLhs
     lhs = Lhs.new
     lhs.ident = parseIdentifier()
     return lhs
  end

  def parseRhs rhsKind 
    puts "Parsing Rhs"
    rhs = Rhs.new
    tmpRhs = rhs.clone
    tmpStream = @lexer.stream.clone

    # Identifier
    begin
      rhs.ident=parseIdentifier()

      if (showNext.kind==:altern || showNext.kind==:concat)&& rhsKind ==1#important semantiquemnt
        raise "continuing error"
      end
      puts "Parsing I"
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      return rhs
    end
    # Terminal
    rhs = Rhs.new
    begin
      rhs.terminal = parseTerminal()
      if (showNext.kind==:altern || showNext.kind==:concat)&& rhsKind ==1
        raise "continuing error"
      end
      puts "Parsing T"
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      return rhs
    end
    # [rhs]
    rhs = Rhs.new
    begin
      expect :loption
      puts "Parsing [Rhs]"
      rhs.optRhs=parseRhs(1)
      expect :roption
      if (showNext.kind==:altern || showNext.kind==:concat)&& rhsKind ==1#important semantiquemnt
        raise "continuing error"
      end
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      return rhs
    end
    # {rhs}
    rhs = Rhs.new
    begin
      expect :lrepetition
      puts "Parsing {Rhs}"
      rhs.repRhs=parseRhs(1)
      expect :rrepetition
      if (showNext.kind==:altern || showNext.kind==:concat)&& rhsKind ==1#important semantiquemnt
        raise "continuing error"
      end
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      puts "end {}"
      return rhs
    end
    # (rhs)
    rhs = Rhs.new
    begin
      expect :lgrouping
      puts "Parsing (Rhs)"
      rhs.groupRhs=parseRhs(1)
      expect :rgrouping
      if (showNext.kind==:altern || showNext.kind==:concat)&& rhsKind ==1#important semantiquemnt
        raise "continuing error"
      end
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      return rhs
    end
    # rhs | rhs
    rhs = Rhs.new 
    begin
      rhs.altRhs << parseRhs(0)
      expect :altern
      puts "Parsing |"
      rhs.altRhs << parseRhs(1)
    rescue
      set_Stream(tmpStream)
      tmpStream = tmpStream.clone
    else
      puts "end alt" 
      return rhs
    end
    # rhs , rhs
    rhs = Rhs.new
    rhs.concRhs << parseRhs(0)
    expect :concat
    puts "Parsing ,"
    rhs.concRhs << parseRhs(1)
    return rhs
  end

  def parseTerminal
    puts "Parsing Terminal"
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
          puts "#{showNext.value}"
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
    puts "Parsing ident"
    ident = Identifier.new
    ident.letter = parseChar()
    continue = true
    while (continue)
      tmpStream=@lexer.stream.clone
      tmpIdent = ident.clone
      begin
        ident.alphaNum << parseAlphaNum()
      rescue
        continue=false
        set_Stream(tmpStream)
        ident = tmpIdent
      end
    end 
    return ident
  end

  def parseAlphaNum
    tmpStream = @lexer.stream.clone
    alphaNum = AlphaNum.new
    begin
      alphaNum.letter = parseChar()
    rescue
      set_Stream(tmpStream)
    else
      return alphaNum
    end
    alphaNum = AlphaNum.new
    begin
      alphaNum.digit = parseDig()
    rescue
      set_Stream(tmpStream)
    else
      return alphaNum
    end
    alphaNum = AlphaNum.new
    alphaNum.under = (expect :under).value
    return alphaNum
  end

  def parseCharacter 
    tmpStream = @lexer.stream.clone
    character = Character.new
    begin
      character.letter = parseChar()
    rescue
      set_Stream(tmpStream)#reput the token on first place of the lexer stream
    else
      return character
    end
    character = Character.new
    begin
      character.digit = parseDig()
    rescue
      set_Stream(tmpStream)
    else
      return character
    end
    character = Character.new
    begin
      character.symbol = parseSym()
    rescue
      set_Stream(tmpStream)
    else
      return character
    end 
    character = Character.new
    character.under = (expect :under).value
    return character
  end  

  def parseChar
    if !@dic.isLetter(showNext())
        #@dic.printDicLetter
	puts "expecting letter. Got #{showNext.kind} at #{showNext.pos} (#{showNext.value})"
        raise "parsing error"
    end
    letter = Letter.new
    letter.letter = acceptIt.value
    return letter
  end

  def parseDig
    if !@dic.isDigit(showNext())
	puts "expecting digit. Got #{showNext.kind} at #{showNext.pos} (#{showNext.value})"
        raise "parsing error"
    end
    digit = Digit.new
    digit.digit = acceptIt.value
    return digit
  end

  def parseSym
    if !@dic.isSymbol(showNext())
	puts "expecting symbol. Got #{showNext.kind} at #{showNext.pos} (#{showNext.value})"
        raise "parsing error"
    end
    symbol = Symbol_.new
    symbol.symbol = acceptIt.value
    return symbol
  end
  #=============parse Dictionnary =================
  def parseTMPCHAR
    expect :terminalstr2
    @dic.addLetter(showNext())
    acceptIt
    expect :terminalstr2
  end

  def parseTMPDIG
    expect :terminalstr2
    @dic.addDigit(showNext())
    acceptIt
    expect :terminalstr2
  end

  def parseTMPSYM #TODO work only with unique token 
    expect :terminalstr2
    @dic.addSymbol(showNext)
    acceptIt
    expect :terminalstr2
  end 

  def parseLetter
    expect :def
    parseTMPCHAR()
    while showNext.kind == :altern
    	expect :altern
        parseTMPCHAR()
    end
    expect :term
  end

  def parseDigit
    expect :def
    parseTMPDIG()
    while showNext.kind == :altern
    	expect :altern
        parseTMPDIG()
    end
    expect :term
  end 

  def parseSymbol
    expect :def
    parseTMPSYM()
    while showNext.kind == :altern
    	expect :altern
        parseTMPSYM()
    end
    expect :term
  end
 #==================================================
end
