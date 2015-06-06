require 'pp'
require_relative 'lexer'

TokenDic=Struct.new(:number,:value)

class Dicode
  attr_accessor :dicTerminal
  attr_accessor :dicIdentifier
  attr_accessor :dicIdentifierCalled

  def initialize
    @dicTerminal = []
    @dicIdentifier = []
    @dicIdentifierCalled = []
  end

 #Terminal
  def addTerminal terminal
    if (isTerminal(terminal))
      return terminal
    end
    if @dicTerminal==[]
      @dicTerminal << TokenDic.new(1,terminal)
    else
      @dicTerminal << TokenDic.new((@dicTerminal.last.number)+1,terminal)
    end
    return terminal
  end

  def isTerminal terminal
    tmpDicTerminal=@dicTerminal.clone
    while tmpDicTerminal.first!=nil
      tok = tmpDicTerminal.shift
      if tok.value==terminal
        return true
      end
    end
    return false
  end

  def getTerminalNumber value
    tmpDicTerminal=@dicTerminal.clone
    while tmpDicTerminal.first!=nil
      tok = tmpDicTerminal.shift
      if tok.value==value
        return tok.number
      end
    end
    addTerminal value
    getTerminalNumber value
  end

  #Identifier
  def addIdentifier identifier
    if (isIdentifier(identifier))
      return identifier
    end
    if @dicIdentifier==[]
      @dicIdentifier << TokenDic.new(1,identifier)
    else
      @dicIdentifier << TokenDic.new((@dicIdentifier.last.number)+1,identifier)
    end
    return identifier
  end

  def isIdentifier identifier
    tmpDicIdentifier=@dicIdentifier.clone
    while tmpDicIdentifier.first!=nil
      tok = tmpDicIdentifier.shift
      if tok.value==identifier
        return true
      end
    end
    return false
  end

  def getIdentifierNumber value
    tmpDicIdentifier=@dicIdentifier.clone
    while tmpDicIdentifier.first!=nil
      tok = tmpDicIdentifier.shift
      if tok.value==value
        return tok.number
      end
    end
    addIdentifier value
    getIdentifierNumber value
  end

  #IdentifierCalled
  def addIdentifierCalled identifierCalled
    if (isIdentifierCalled(identifierCalled))
      return identifierCalled
    end
    if @dicIdentifierCalled==[]
      @dicIdentifierCalled << TokenDic.new(1,identifierCalled)
    else
      @dicIdentifierCalled << TokenDic.new((@dicIdentifierCalled.last.number)+1,identifierCalled)
    end
    return identifierCalled
  end

  def isIdentifierCalled identifierCalled
    tmpDicIdentifierCalled=@dicIdentifierCalled.clone
    while tmpDicIdentifierCalled.first!=nil
      tok = tmpDicIdentifierCalled.shift
      if tok.value==identifierCalled
        return true
      end
    end
    return false
  end

  def getIdentifierCalledNumber value
    tmpDicIdentifierCalled=@dicIdentifierCalled.clone
    while tmpDicIdentifierCalled.first!=nil
      tok = tmpDicIdentifierCalled.shift
      if tok.value==value
        return tok.number
      end
    end
    addIdentifierCalled value
    getIdentifierCalledNumber value
  end

  def uncalledIdent lhsIdent
    @output = ""
    lhsIdent.each{|decl| check(decl.value)}
    return @output
  end
  
  def check(decl)
    @output=decl if !isIdentifierCalled(decl)
  end

end
