require_relative 'ast'
require_relative 'dictCodeWrit'

class ErrorDetector
  attr_accessor :missing
  attr_accessor :dico

  def initialize print=true,dicoFull
    @indent=0
    @print = print
    @dico = Dicode.new
    @dicoFull = dicoFull
    @missing =[]
  end
  
  def indent
    @indent+=1
  end

  def desindent
    @indent-=1
  end

  def doIt ast
    puts "  ==> applying ErrorDetection visit on ast"
    self.visitModul(ast,nil)
    detectMissingRule
  end
  
  def detectMissingRule
    identToCheck = @dicoFull.dicIdentifier.keys
    identToCheck.each{|decl| checkPresence(decl)}
  end

  def checkPresence decl
    puts "Warnings: #{decl} got no rule" if !@dico.isIdentifier(decl)
    @missing << decl if !@dico.isIdentifier(decl)
  end

  def say txt
    puts " "*@indent+txt if @print
  end

  def espa number=0
    " "*(2*@indent+number)
  end

  def visitModul(modul,args=nil)
    say "visitModul"
    
    modul.grammar.accept(self,args)
    
  end

  def visitGrammar(grammar,args=nil)
    say "visitGrammar"
    grammar.rule.each{|decl| decl.accept(self,nil)}
  end

  def visitRule(rule,args=nil)
    @dico.addIdentifier(rule.lhs.ident.to_s)
    #rule.lhs.accept(self,args)
    #rule.rhs.accept(self,args)
  end

=begin if needed for futur implementations

  def visitLhs(lhs,args=nil)
    say "visitLhs"
    lhs.ident.accept(self,nil)
    
  end

  def visitRhs(rhs,args=nil)
    say "visitRhs"    
    rhs2,name = rhs.returnObjNam
    self.send("ecritRhs#{name}".to_sym, rhs,args)
  end

  def visitTerminal(terminal,args=nil)
    
  end

  def visitIdentifier(identifier,args=nil)
    
  end


  
  def ecritRhsident rhs,args=nil
    rhs.ident.accept(self,nil)
    
  end

  def ecritRhsterminal rhs,args=nil
    
    rhs.terminal.accept(self,nil)
   
  end

  def ecritRhsoptRhs rhs,args=nil
    
    rhs.optRhs.accept(self,args)

  end

  def ecritRhsrepRhs rhs,args=nil
    
    rhs.repRhs.accept(self,args)
  end
  
  def ecritRhsgroupRhs rhs,args=nil
    #TODO
    rhs.groupRhs.accept(self,args)
  end

  def ecritRhsaltRhs rhs,args=nil

    rhs.altRhs[0].accept(self,args)
    
    rhs.altRhs[1].accept(self,args)
  end
  
  def ecritRhsconcRhs rhs,args=nil

    rhs.concRhs[0].accept(self,args)

    rhs.concRhs[1].accept(self,args)
  end
=end
end
