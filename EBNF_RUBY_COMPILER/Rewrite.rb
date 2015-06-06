require_relative 'ast'

class Rewriter

  def initialize print=true
    @indent=0
    @file = File.open("./output/output_rewrite.txt","w")
    @fichier = @file 
    @print=print
  end
  
  def indent
    @indent+=2
  end

  def desindent
    @indent-=2
  end

  def doIt ast
    puts "==> applying Simple Rewrite visit on ast"
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
    @file.close
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
    @fichier.write " \;\n"
    desindent
  end

  def visitLhs(lhs,args=nil)
    say "visitLhs"
    indent
    lhs.ident.accept(self,nil)
    @fichier.write " ="
    desindent
  end

  def visitRhs(rhs,args=nil)
    say "visitRhs"
    indent
    @fichier.write " "
    if rhs.returnObj.kind_of?(Array)
      val=true
      rhs.returnObj.each{|decl| val=doIn(decl,rhs,val)}
    else 
      writeLRhsPart(rhs)
      rhs.returnObj.accept(self,nil)
      writeRRhsPart(rhs)
    end
    desindent
  end

  def doIn(decl,rhs,val)
    decl.accept(self,nil) 
    writeDRhsPart(rhs) if val
    val=false
  end

  def writeDRhsPart(obj)
    if obj.altRhs!=[]
      @fichier.write "\n        \|"
    else
      @fichier.write " \,"
    end
  end

  def writeLRhsPart(obj)
    if obj.groupRhs!=nil
      @fichier.write "\("
    elsif obj.optRhs!=nil
      @fichier.write "\["
    elsif obj.repRhs!=nil
      @fichier.write "\{"
    end
  end

  def writeRRhsPart(obj)
    if obj.groupRhs!=nil
      @fichier.write " \)"
    elsif obj.optRhs!=nil
      @fichier.write " \]"
    elsif obj.repRhs!=nil
      @fichier.write " \}"
    end
  end

  def visitTerminal(terminal,args=nil)
    say "visitTerminal"
    indent
    
    @fichier.write "\""
    terminal.character.each{|decl| decl.accept(self,nil)}
    @fichier.write "\""
    desindent
  end

  def visitIdentifier(identifier,args=nil)
    say "visitIdentifier"
    indent()
    identifier.letter.accept(self,nil)
    identifier.alphaNum.each{|decl| decl.accept(self,nil)}
    desindent()
  end

  def visitAlphaNum(alphaNum,args=nil)
    
    if !alphaNum.returnObj.kind_of?(Letter) && !alphaNum.returnObj.kind_of?(Digit)
      say alphaNum.returnObj.value
      @fichier.write alphaNum.returnObj.value
    else
      alphaNum.returnObj.accept(self,nil)
    end
    
  end

  def visitCharacter(character,args=nil)
    
    indent
    if !character.returnObj.kind_of?(Letter) && !character.returnObj.kind_of?(Digit) && !character.returnObj.kind_of?(Symbol_)
      say character.returnObj
      @fichier.write character.returnObj
    else
      character.returnObj.accept(self,nil)
    end
    desindent
  end

  def visitLetter(letter,args=nil)
    say letter.to_s
    @fichier.write letter.to_s
  end
 
  def visitDigit(digit,args=nil)
    say digit.to_s
    @fichier.write digit.to_s
  end

  def visitSymbol_(symbol,args=nil)
    say symbol.to_s
    @fichier.write symbol.to_s
  end
end

