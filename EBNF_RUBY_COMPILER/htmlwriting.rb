require_relative 'ast'

class HtmlWriting

  attr_accessor :name,:text

  def initialize print=true,name="output_html",error=[],uncalled=[]
    @file = File.open("./output/output_html.html","w")
    @fichier = @file 
    @print=print
    @name = name
    @text=""
    @error=error
    @uncalled=uncalled
  end

  def doIt ast
    puts "==> applying Html Writing on ast"
    self.visitModul(ast,nil)
  #====== Writing File ======

    htmlwriting=self
    string=IO.read "template_html.txt"
    engine = ERB.new(string)
    generated_code= engine.result(binding)

    write generated_code
    @file.close
  #=========================
  end

  def addTxt txt
    @text << (""+txt)
  end

  def write txt
    @fichier.write txt
  end

  def say txt
    puts txt if @print
  end

  def writeS(number,text)
    "\<s#{number}\>#{text}\<\/s#{number}\>"
  end

  def visitModul(modul,args=nil)
   
    modul.grammar.accept(self,args)
    
  end

  def visitGrammar(grammar,args=nil)
    
    grammar.rule.each{|decl| decl.accept(self,nil)}
    
  end

  def visitRule(rule,args=nil)
    tmp,name= rule.rhs.returnObjNam
    args = rule.lhs.ident.to_s.length
    rule.lhs.accept(self,nil)
    rule.rhs.accept(self,args)
    addTxt writeS(4," \;\n")
    
  end

  def visitLhs(lhs,args=nil)
    
    lhs.ident.accept(self,nil)
    addTxt writeS(3," =")
    
  end

  def visitRhs(rhs,args=nil)
    
    addTxt " "
    if rhs.returnObj.kind_of?(Array)
      val=true
      rhs.returnObj.each{|decl| val=doIn(decl,rhs,val,args)}
    else 
      writeLRhsPart(rhs)
      rhs.returnObj.accept(self,nil)
      writeRRhsPart(rhs)
    end
    
  end

  def doIn(decl,rhs,val,args)
    nn=args
    args = nil if val
    decl.accept(self,args) 
    writeDRhsPart(rhs,nn) if val #check if first part of altern or concat 
    val=false
  end

  def writeDRhsPart(obj,args) #write | or ,
    if obj.altRhs!=[] && args!=nil
     if obj.altRhs[1].altRhs!=[]
       addTxt writeS(2,"\n"+" "*(args+1)+"\|")
     else
       addTxt writeS(2,"\n"+" "*(args+1)+"\| ")# add space for design purpose
     end
    elsif obj.altRhs!=[]
      addTxt writeS(2,"\|")
    else
      addTxt writeS(2," \,")
    end
  end

  def writeLRhsPart(obj) #write left part of {} [] ()
    if obj.groupRhs!=nil
      addTxt writeS(1,"\(")
    elsif obj.optRhs!=nil
      addTxt writeS(1,"\[")
    elsif obj.repRhs!=nil
      addTxt writeS(1,"\{")
    end
  end

  def writeRRhsPart(obj) #write right part of {} [] ()
    if obj.groupRhs!=nil
      addTxt writeS(1," \)")
    elsif obj.optRhs!=nil
      addTxt writeS(1," \]")
    elsif obj.repRhs!=nil
      addTxt writeS(1," \}")
    end
  end

  def visitTerminal(terminal,args=nil)
    addTxt writeS(5,"\"")
    addTxt writeS(5,terminal.to_s)
    addTxt writeS(5,"\"")
  end

  def visitIdentifier(identifier,args=nil)
    if @error.include?(identifier.to_s) 
      addTxt writeS(0,identifier.to_s)
    elsif @uncalled.include?(identifier.to_s)
      addTxt writeS(6,identifier.to_s)
    else
      addTxt identifier.to_s
    end
  end
end
