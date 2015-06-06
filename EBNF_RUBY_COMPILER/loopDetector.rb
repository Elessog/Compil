require_relative 'ast'

class LoopDetector
  attr_accessor :loop

  def initialize
    @loop=[]
  end
  

  def doIt ast
    puts "  ==> applying Loop Detection visit on ast"
    self.visitModul(ast,nil)
  end



  def visitModul(modul,args=nil)
    modul.grammar.accept(self,args)
    
  end

  def visitGrammar(grammar,args=nil)
    grammar.rule.each{|decl| decl.accept(self,nil)}
  end

  def visitRule(rule,args=nil)
    rule.lhs.accept(self,nil)
   
    rule.rhs.accept(self,rule.lhs.ident.to_s)
  end

  def visitLhs(lhs,args=nil)
  end

  def visitRhs(rhs,args=nil)  
    rhs2,name = rhs.returnObjNam
    self.send("ecritRhs#{name}".to_sym, rhs,args)
  end
  
  def ecritRhsident rhs,args=nil
    puts "    Futur Loop detection : #{rhs.ident.to_s}" if rhs.ident.to_s==args
    @loop << rhs.ident.to_s if rhs.ident.to_s==args 
  end

  def ecritRhsterminal rhs,args=nil
  end

  def ecritRhsoptRhs rhs,args=nil
    rhs.optRhs.accept(self,args)
  end

  def ecritRhsrepRhs rhs,args=nil
    rhs.repRhs.accept(self,args)
  end
  
  def ecritRhsgroupRhs rhs,args=nil
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
end

