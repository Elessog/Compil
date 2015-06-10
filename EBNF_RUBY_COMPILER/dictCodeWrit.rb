class Dicode
  attr_accessor :dicTerminal
  attr_accessor :dicIdentifier
  attr_accessor :dicIdentifierCalled

  def initialize
    @dicTerminal = {}
    @dicIdentifier = {}
    @dicIdentifierCalled = {}
  end

  def addHach hach,value
    hach[value]=hach.length+1 if !hach.has_key?(value)
    value
  end

  def isInHach hach,value
    hach.has_key?(value)
  end

  def getNumber hach,value
    hach[value]
  end

 
 #Terminal
  def addTerminal terminal
    addHach @dicTerminal,terminal
  end

  def isTerminal terminal
    isInHach @dicTerminal,terminal
  end

  def getTerminalNumber value
    addTerminal value if !isTerminal(value)
    getNumber @dicTerminal,value
  end

  #Identifier
  def addIdentifier identifier
    addHach @dicIdentifier,identifier
  end

  def isIdentifier identifier
    isInHach @dicIdentifier,identifier
  end

  def getIdentifierNumber value
    addIdentifier value if !isIdentifier(value)
    getNumber @dicIdentifier,value
  end

  #IdentifierCalled
  def addIdentifierCalled identifierCalled
    addHach @dicIdentifierCalled,identifierCalled
  end

  def isIdentifierCalled identifierCalled
    isInHach @dicIdentifierCalled,identifierCalled
  end

  def getIdentifierCalledNumber value
    addIdentifierCalled value if !isIdentifierCalled
    getNumber @dicIdentifierCalled,value
  end

  def uncalledIdent lhsIdent
    @output = ""
    lhsIdent.each{|decl| check(decl)}
    return @output
  end
  
  def check(decl)
    @output=decl if !isIdentifierCalled(decl)
  end

end
