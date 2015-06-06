require_relative 'ast'
require 'erb'

NewClass = Struct.new(:ident,:nodes)

class AstWriting
  attr_accessor :rules  
  attr_accessor :dico

  def initialize print=true
    @indent=0
    @print =print
    @rules=[]
    @stringClass=IO.read "template_class_ast.txt"
    @engineClass = ERB.new(@stringClass) #initialization of template for class writing
    @file = File.open("./output/output_astwriting.rb","w")
    @fichier = @file 
    @print = print
    @hachClass = {}
  end
  
  def indent
    @indent+=2
  end

  def desindent
    @indent-=2
  end

  def doIt ast
    puts "==> applying Ast Writing on ast"
    self.visitModul(ast,nil)
    #===== Writing =====
    astwriting=self
    string=IO.read "template_ast.txt"
    engine = ERB.new(string)
    result = engine.result(binding)

    write result
    @file.close
    #===================

    return @hachClass
  end

  def say txt
    puts " "*@indent+txt if @print
  end

  def write txt
    @fichier.write txt
  end
  #===== Hachage ==========
  def initHach
    @hach = {}  
  end 

  def addValue (key,value)
    if !@hach.has_key?(key)
      @hach[key]=value
    elsif @hach[key].kind_of?(Array)
      @hach[key] << value
    else
      @hach[key] = [@hach[key] , value]
    end
  end

  def processHach
     keys = @hach.keys
     node = []
     for i in keys
        self.initHach2
        if @hach[i].kind_of?(Array)
          @hach[i].each{|ident| node << [i,addValue2(ident,i)]}
        else
          node << [i,(i+@hach[i]+"_1")]
        end
     end
     return node
  end

  def initHach2
    @hach2 = {}  
  end 

  def addValue2(key,i)
    if !@hach2.has_key?(key)
      @hach2[key]=1
    else
      @hach2[key] = @hach2[key]+1
    end
    return (i+key+"_"+@hach2[key].to_s)
  end


  #==========================

  def visitModul(modul,args=nil)
    
    modul.grammar.accept(self,args)
   
  end

  def visitGrammar(grammar,args=nil)
    
    grammar.rule.each{|decl| decl.accept(self,nil)}
    
  end

  def visitRule(rule,args=nil)
    
    ruleClass = NewClass.new
    ruleClass.ident = rule.lhs.ident.to_s
    
    args = ArgPass.new("")
    self.initHach
    rule.rhs.accept(self,args)
    ruleClass.nodes = self.processHach
    
    classText = @engineClass.result(binding)
    @rules << classText 
    @hachClass[ruleClass.ident]=ruleClass
  end

  def visitRhs(rhs,args=nil)
    
    rhs2,name = rhs.returnObjNam
    self.send("ecritRhs#{name}".to_sym, rhs,args.clone)
  end



  def ecritRhsident rhs,args=nil
    self.addValue(args.placement,rhs.ident.to_s)
  end

  def ecritRhsterminal rhs,args=nil
       
  end

  def ecritRhsoptRhs rhs,args=nil
    args = args.clone
    args.placement << "o"
    rhs.optRhs.accept(self,args)

  end

  def ecritRhsrepRhs rhs,args=nil
    args = args.clone
    args.placement << "r"
    rhs.repRhs.accept(self,args)
  end
  
  def ecritRhsgroupRhs rhs,args=nil
    #TODO
    args = args.clone
    args.placement << "g"
    rhs.groupRhs.accept(self,args)
  end

  def ecritRhsaltRhs rhs,args=nil
    args2= args.clone
    args = args.clone
    args.placement << "a"
    
    rhs.altRhs[0].accept(self,args)

    r,name= rhs.altRhs[1].returnObjNam
    args2.placement << "a" if name!="altRhs"
    rhs.altRhs[1].accept(self,args2)
  end
  
  def ecritRhsconcRhs rhs,args=nil
    
    rhs.concRhs[0].accept(self,args.clone)

    rhs.concRhs[1].accept(self,args.clone)
  end

end

class ArgPass
   attr_accessor :placement
   
   def initialize placement=nil
      @placement = placement 
   end

   def clone
     ArgPass.new(@placement.clone)
   end
end
