#TODO make transition to optmised code (see below first class)

require 'pp'
require_relative 'lexer'

class Dictionnaire
  attr_accessor :dicLetter
  attr_accessor :dicDigit
  attr_accessor :dicSymbol

  def initialize
    @dicLetter = []
    @dicDigit = []
    @dicSymbol = []
  end

  def addLetter letter
    if (isLetter(letter) || isDigit(letter) || isSymbol(letter))
      puts "letter #{letter.value} at #{letter.pos} is already in dicLetter or in another dictionary"
      raise "parsing error"
    end
    @dicLetter << letter
  end

  def addDigit digit
    if (isLetter(digit) || isDigit(digit) || isSymbol(digit))
      puts "digit #{digit.value} at #{digit.pos} is already in dicDigit or in another dictionary"
      raise "parsing error"
    end
    @dicDigit << digit
  end

  def addSymbol symbol
    if (isLetter(symbol) || isDigit(symbol) || isSymbol(symbol))
      puts "symbol #{symbol.value} at #{symbol.pos} is already in dicSymbol or in another dictionary"
      raise "parsing error"
    end
    @dicSymbol << symbol
  end

  def isLetter letter
    tmpDicLetter=@dicLetter.clone
    while tmpDicLetter.first!=nil
      tok = tmpDicLetter.shift
      if tok.kind==letter.kind && tok.value==letter.value
        
        return true
      end
        
    end
    return false
  end

  def isDigit digit
    tmpDicDigit=@dicDigit.clone
    while tmpDicDigit.first!=nil
      tok = tmpDicDigit.shift
      if tok.kind==digit.kind && tok.value==digit.value
        
        return true
      end
    end
    return false
  end

  def isSymbol symbol
    tmpDicSymbol=@dicSymbol.clone
    while tmpDicSymbol.first!=nil
      tok = tmpDicSymbol.shift
      if tok.kind==symbol.kind && tok.value==symbol.value
        return true
      end
    end
    return false
  end

  def printDicLetter
    tmpDicLetter=@dicLetter.clone
    while tmpDicLetter.first!=nil
      tok = tmpDicLetter.shift
      puts " #{tok.value}"
    end
  end

  def printDicDigit
    tmpDicDigit=@dicDigit.clone
    while tmpDicDigit.first!=nil
      tok = tmpDicDigit.shift
      puts " #{tok.value}"
    end
  end
end
##########################################################################################################
class DictionnaireForWait
  attr_accessor :dicLetter
  attr_accessor :dicDigit
  attr_accessor :dicSymbol

  def initialize
    @dicLetter = []
    @dicDigit = []
    @dicSymbol = []
  end

  def addLetter letter
    if (isLetter(letter) || isDigit(letter) || isSymbol(letter))
      puts "letter #{letter.value} at #{letter.pos} is already in dicLetter or in another dictionary"
      raise "parsing error"
    end
    @dicLetter << letter.value
  end

  def addDigit digit
    if (isLetter(digit) || isDigit(digit) || isSymbol(digit))
      puts "digit #{digit.value} at #{digit.pos} is already in dicDigit or in another dictionary"
      raise "parsing error"
    end
    @dicDigit << digit.value
  end

  def addSymbol symbol
    if (isLetter(symbol) || isDigit(symbol) || isSymbol(symbol))
      puts "symbol #{symbol.value} at #{symbol.pos} is already in dicSymbol or in another dictionary"
      raise "parsing error"
    end
    @dicSymbol << symbol.value
  end

  def isLetter letter
    @dicLetter.include?(letter.value)
  end

  def isDigit digit
    @dicDigit.include?(digit.value)
  end

  def isSymbol symbol
    @dicSymbol.include?(digit.value)
  end

  def printDicLetter
    puts @dicLetter
  end

  def printDicDigit
    puts @dicDigit
  end

end
