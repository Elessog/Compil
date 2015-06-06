require_relative 'ast'

class Visitor

  def initialize print=true
    @indent=0
    @print =print
  end
  
  def indent
    @indent+=2
  end

  def desindent
    @indent-=2
  end

  def doIt ast
    puts "==> applying visit on ast"
    self.visitModul(ast,nil)
  end

  def say txt
    puts " "*@indent+txt if @print
  end

  def visitModul(modul,args=nil)
    say "visitModul"
    indent()
    modul.grammar.accept(self,args)
    desindent()
  end

  def visitGrammar(grammar,args=nil)
    say "visitGrammar"
    indent
    grammar.rule.each{|decl| decl.accept(self,nil)}
    desindent
  end

  def visitRule(rule,args=nil)
    say "visitRule"
    indent
    rule.lhs.accept(self,nil)
    rule.rhs.accept(self,nil)
    desindent
  end

  def visitLhs(lhs,args=nil)
    say "visitLhs"
    indent
    lhs.ident.accept(self,nil)
    desindent
  end

  def visitRhs(rhs,args=nil)
    say "visitRhs"
    indent
    if rhs.returnObj.kind_of?(Array)
      rhs.returnObj.each{|decl| decl.accept(self,nil)}
    else 
      rhs.returnObj.accept(self,nil)
    end
    desindent
  end

  def visitTerminal(terminal,args=nil)
    say "visitTerminal"
    indent
    say terminal.to_s#terminal.character.each{|decl| decl.accept(self,nil)}
    desindent
  end

  def visitIdentifier(identifier,args=nil)
    say "visitIdentifier"
    indent()
    say identifier.to_s
    #identifier.letter.accept(self,nil)
    #identifier.alphaNum.each{|decl| decl.accept(self,nil)}
    desindent()
  end

  def visitAlphaNum(alphaNum,args=nil)
    
    if !alphaNum.returnObj.kind_of?(Letter) && !alphaNum.returnObj.kind_of?(Digit)
      say alphaNum.returnObj.value
    else
      alphaNum.returnObj.accept(self,nil)
    end
    
  end

  def visitCharacter(character,args=nil)
    
    indent
    if !character.returnObj.kind_of?(Letter) && !character.returnObj.kind_of?(Digit) && !character.returnObj.kind_of?(Symbol_)
      say character.returnObj
    else
      character.returnObj.accept(self,nil)
    end
    desindent
  end

  def visitLetter(letter,args=nil)
    say letter.to_s
  end
 
  def visitDigit(digit,args=nil)
    say digit.to_s
  end

  def visitSymbol_(symbol,args=nil)
    say symbol.to_s
  end
end

