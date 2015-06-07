require_relative 'ast'
require_relative 'dictCodeWrit'
require_relative 'errorDetector'
require_relative 'loopDetector'
require 'erb'

NameRule=Struct.new(:name,:bool,:ast,:loopTerm,:advance,:placement)

class CodeWriting
  attr_accessor :dico
  attr_accessor :text
  attr_accessor :missingRules
  attr_accessor :uncalledRule

  def initialize print=true
    @indent=0
    @file = File.open("./output/output_codewriting.rb","w")
    @fichier = @file 
    @print = print
    @dico = Dicode.new
    @text = ""

    @loopIdent =[]

    @missingRules=nil
    @uncalledRule=nil
    @hach={}
  
  end
  
  def indent
    @indent+=1
  end

  def desindent
    @indent-=1
  end

  def doIt ast
    puts "==> applying Code Writing visit on ast"
  
  #====== Loop Detection ======
    loopDetector = LoopDetector.new
    loopDetector.doIt ast
    @loopIdent = loopDetector.loop

  #======= Visitor ============
    self.visitModul(ast,nil) #Start of the code generation

  #====== Error Detection ======
    errorDetector = ErrorDetector.new(false,@dico)
    errorDetector.doIt ast
    @missingRules=errorDetector.missing
    @uncalledRule = @dico.uncalledIdent(errorDetector.dico.dicIdentifier.keys)
    puts "Warning No primary rule for Parser" if @uncalledRule==""

  #====== Writing File ======

    codewriting=self
    string=IO.read "template_parser.txt"
    engine = ERB.new(string)
    generated_code= engine.result(binding)

    write generated_code
    @file.close
  #=========================
  end

  def say txt
    puts " "*@indent+txt if @print
  end

  def addTxt txt
    @text << (""+txt)
  end

  def write txt
    @fichier.write txt
  end

  def espa number=0
    " "*(2*@indent+number)
  end

  #====== AST Related ============
  def initHach
    @hach = {}  
  end 

  def addValue (key,value)
    if !@hach.has_key?(key)
      @hach[key]=value
      return 1
    elsif @hach[key].kind_of?(Array)
      @hach[key] << value
      return @hach[key].count(value)
    else
      @hach[key] = [@hach[key] , value]
      return @hach[key].count(value)
    end
  end
  #================================

#============= Visit of ast and Code generation ========================================#
  def visitModul(modul,args=nil)
    say "visitModul"
    indent()
    modul.grammar.accept(self,args)
    desindent()
  end

  def visitGrammar(grammar,args=nil)
    say "visitGrammar"
    grammar.rule.each{|decl| decl.accept(self,grammar)}
  end

  def visitRule(rule,args=nil)
    say "visitRule"
    rule.lhs.accept(self,nil)
    
    #loop info
    args = NameRule.new([rule.lhs.ident.to_s],false,args) #allow to now the name of the rule while in the tree and the tree itself
    args.bool = true if @loopIdent.include?(rule.lhs.ident.to_s)
    #================ LOOP avoidance (in output parser) ==================
    args1 = args.clone
    if args1.bool
      rhs = rule.rhs
      rhs3,name3 =rhs.returnObjNam
      lisTerm=[]
      boolAlt =false
      while name3=="altRhs"#visit of altRhs
        boolAlt=true
        rshTmp,nameTmp = rhs3[0].groupRhs.returnObjNam
        if nameTmp=="concRhs"
          rshTmp,nameTmp = rhs3[0].groupRhs.returnObj[0].returnObjNam
          rshTmp2 = rhs3[0].groupRhs.returnObj[1].concRhs[0]
          if nameTmp=="ident"
            if rshTmp.to_s == args1.name.first #adding term
              term = rshTmp2.returnTerminal(args1)
              tt,name4 = rshTmp2.returnObjNam
              bool=false
              bool,dico = rshTmp2.groupRhs.isOnlyTerminal([],args1) if name4=="groupRhs"
              if bool
                bool,dico = rshTmp2.groupRhs.isOnlyTerminal([],args1)
                dico.each{|term1| lisTerm << term1 if !lisTerm.include?(term1)}
              else
                lisTerm << term if !lisTerm.include?(term.to_s)
              end
            end
          end
          rhs3,name3 =rhs3[1].returnObjNam
        else
          rhs3,name3 =rhs3[1].returnObjNam
        end
      end
  
      if boolAlt #last altRhs, the right part 
        rshTmp,nameTmp = rhs3.returnObjNam
        
        if nameTmp=="concRhs"
          rshTmp,nameTmp = rhs3.returnObj[0].returnObjNam
          rshTmp2 = rhs3.returnObj[1].concRhs[0]
          if nameTmp=="ident"
            if rshTmp.to_s == args1.name.first #adding term
              term = rshTmp2.returnTerminal(args1)
              tt,name4 = rshTmp2.returnObjNam
              bool=false
              bool,dico = rshTmp2.groupRhs.isOnlyTerminal([],args1) if name4=="groupRhs"
              
              if bool
                bool,dico = rshTmp2.groupRhs.isOnlyTerminal([],args1)
                dico.each{|term1| lisTerm << term1 if !lisTerm.include?(term1)}
              else
                lisTerm << term if !lisTerm.include?(term.to_s)
              end
            end
          end
        end
      end
      args.loopTerm=lisTerm
      tmp,name = rhs.returnObjNam #useless line because language where a method call itself without altern would not be viable (so dont catch an entire rule with parenthesis)
      args.advance= false if lisTerm!=[] && name=="altRhs" #if false mean we have to modify call to self (method)  
    end
    
    addTxt " checkNeeded = true"    if lisTerm!=[] && lisTerm!=nil

    
    addTxt "\n"
    #=================

    #===== AST =======
    self.initHach
    args.placement=""
    #=================
    
    indent
    addTxt espa+args.name.first.downcase+" \= "+args.name.first.upcase+"\.new\n"
    rule.rhs.accept(self,args)
    addTxt espa+args.name.first.downcase+"\n"
    desindent
    addTxt "\n"+espa+"end\n\n"
  end

  def visitLhs(lhs,args=nil)
    say "visitLhs"
    addTxt espa+"def parse"
    lhs.ident.accept(self,nil)
    
  end

  def visitRhs(rhs,args=nil)
    say "visitRhs"    
    rhs2,name = rhs.returnObjNam
    self.send("ecritRhs#{name}".to_sym, rhs,args)
  end

  def visitTerminal(terminal,args=nil)
    say "visitTerminal"
    addTxt @dico.getTerminalNumber(terminal.to_s).to_s
  end

  def visitIdentifier(identifier,args=nil)
    say "visitIdentifier"
    addTxt @dico.addIdentifier(identifier.to_s)
    if args.kind_of?(NameRule)
      @dico.addIdentifierCalled(identifier.to_s) #add to Ident called dictionnary
      addTxt " false" if args.advance==false && args.name.first == identifier.to_s #for loop in output parser
    end
   
   end


  
  def ecritRhsident rhs,args=nil
    #====== AST ======
    addTxt espa+args.name.first.downcase+"\."+objectName(rhs.ident.to_s,args.placement.clone)
    if args.placement.include?("r")
      addTxt " \<\< "
    else
      addTxt " \= "
    end
    #=================
    addTxt "parse"
    rhs.ident.accept(self,args) #to mark that it is a call
    addTxt "\n"
  end

  def objectName ident,placement
     n=addValue(ident,placement)
     placement+ident.downcase+"_#{n}"
  end

  def ecritRhsterminal rhs,args=nil
    addTxt "\n"+espa+"expect :token_"
    rhs.terminal.accept(self,nil)
    addTxt "\n"
  end

  def ecritRhsoptRhs rhs,args=nil
    #TODO
    if args.kind_of?(Array)
      rhs2 = args[1]
      args = args[0]
    else
      rhs2=nil
    end
    term2=nil
    #check if fisrt terminal in rep is same as next terminal if there is
    if rhs2.respond_to? :returnTerminal 
    	term2 = rhs2.returnTerminal(args)
        bool,dico = rhs2.isOnlyTerminal([],args)
        term2=nil if !bool
    elsif rhs2.kind_of?(Terminal)
        term2=rhs2.to_s
    end

    bool=false
    term = nil
    if !rhs.isThereAlt #to be improve 
      term = rhs.returnTerminal(args)
      bool2,dico = rhs.isOnlyTerminal([],args)
      bool = true if (term!=term2)
    end
    
    #==== AST ====
    args= args.clone
    args.placement=args.placement.clone
    args.placement << "o"   
    #================================================================
    
    if bool && term2!=nil #look token after optionnal statement
      addTxt espa+"if showNext.kind \!\= \:token_#{@dico.getTerminalNumber(term2.to_s)}\n"
      indent
      rhs.optRhs.accept(self,args)
      desindent
      addTxt espa+"end\n"
    elsif bool && term!=nil #look first token in optionnal statement
      addTxt espa+"if showNext.kind \=\= \:token_#{@dico.getTerminalNumber(term.to_s)}\n"
      indent
      rhs.optRhs.accept(self,args)
      desindent
      addTxt espa+"end\n"
    else
      addTxt espa+"tmp#{args.name.first}#{@indent}\=#{args.name.first.downcase}\.clone\n"
      addTxt espa+"tmpStream#{@indent}=\@lexer\.stream\.clone\n"
      addTxt espa+"begin\n"
      indent
      rhs.optRhs.accept(self,args)
      desindent
      addTxt "\n"+espa+"rescue\n"
      addTxt espa(2)+"set_Stream(tmpStream#{@indent})\n"
      addTxt espa(2)+"#{args.name.first.downcase}\=tmp#{args.name.first}#{@indent}\n"
      addTxt espa+"end\n"
    end
  end

  def ecritRhsrepRhs rhs,args=nil
    #TODO
    if args.kind_of?(Array)
      rhs2 = args[1]
      args = args[0]
    else
      rhs2=nil
    end
    term2=nil
    #check if fisrt terminal in rep is same as next terminal if there is
    if rhs2.respond_to? :returnTerminal 
    	term2 = rhs2.returnTerminal(args)
        bool,dico = rhs2.isOnlyTerminal([],args)
        term2=nil if !bool
    elsif rhs2.kind_of?(Terminal)
        term2=rhs2.to_s
    end

    bool=false
    term = nil
    if !rhs.isThereAlt
      term = rhs.returnTerminal(args)
      bool2, dico = rhs.isOnlyTerminal([],args)
      if args.name.first == "MethodDeclaration"
       pp term
       pp bool2
       puts "##################"
      end
      term = nil if !bool2
      bool = true if ( term!=term2) 
    end
    if false#args.name.first == "MethodDeclaration"
      pp term
      pp term2
      pp bool
      pp rhs
    end
    #==== AST ====
    args=args.clone
    args.placement=args.placement.clone
    args.placement << "r"   
    #=============
    #====================================================================
    if bool && term2!=nil #we write differently the while statement to get less begin rescue statement
      addTxt espa+"continue_#{@indent} = false\n"
      addTxt espa+"if showNext.kind\!\= \:token_#{@dico.getTerminalNumber(term2.to_s)}\n"
      addTxt espa(2)+"continue_#{@indent} \= true\n"
      addTxt espa+"end\n\n"
      addTxt espa+"while continue_#{@indent}\n"
      indent
      rhs.repRhs.accept(self,args)
      desindent 
      addTxt espa(2)+"if showNext.kind\=\= \:token_#{@dico.getTerminalNumber(term2.to_s)}\n"
      addTxt espa(4)+"continue_#{@indent} \= false\n"
      addTxt espa(2)+"end\n"
      addTxt espa+"end\n"
    elsif bool && term!=nil
      addTxt espa+"continue_#{@indent} = false\n"
      addTxt espa+"if showNext.kind\=\= \:token_#{@dico.getTerminalNumber(term.to_s)}\n"
      addTxt espa(2)+"continue_#{@indent} \= true\n"
      addTxt espa+"end\n\n"
      addTxt espa+"while continue_#{@indent}\n"
      indent
      rhs.repRhs.accept(self,args)
      desindent 
      addTxt espa(2)+"if showNext.kind\!\= \:token_#{@dico.getTerminalNumber(term.to_s)}\n"
      addTxt espa(4)+"continue_#{@indent} \= false\n"
      addTxt espa(2)+"end\n"
      addTxt espa+"end\n"
    else
      addTxt espa+"continue\=true\n"
      addTxt espa+"while continue\n"
      indent
      addTxt espa+"tmp#{args.name.first}#{@indent}\=#{args.name.first.downcase}\.clone\n"
      addTxt espa+"tmpStream#{@indent}=\@lexer\.stream\.clone\n"
      addTxt espa+"begin\n"
      indent
      rhs.repRhs.accept(self,args)
      desindent
      addTxt "\n"+espa+"rescue\n"
      addTxt espa(2)+"set_Stream(tmpStream#{@indent})\n"
      addTxt espa(2)+"#{args.name.first.downcase}\=tmp#{args.name.first}#{@indent}\n"
      addTxt espa(2)+"continue\=false\n"
      addTxt espa+"end\n"
      desindent
      addTxt espa+"end\n"
    end
  end
  
  def ecritRhsgroupRhs rhs,args=nil
    #TODO
    bool,dicotmp = rhs.groupRhs.isOnlyTerminal([],args)
    obj,name = rhs.groupRhs.returnObjNam
    #==== AST ====
    args =args.clone
    args.placement=args.placement.clone
    args.placement << "g"   
    #=============
    if name != "altRhs"
      rhs.groupRhs.accept(self,args)
    elsif bool
      addTxt espa + "tmpKind \= showNext.kind\n"
      addTxt espa + "case tmpKind\n"
      
      @altCount = dicotmp.count
      @tmpAltern = rhs.groupRhs
      indent
      dicotmp.each{|decl| writeCase(decl,args)}
      desindent
      addTxt espa+"else\n"
      addTxt espa(2)+"raise \"erreur\"\n"
      addTxt espa+"end\n"
     else
       rhs.groupRhs.accept(self,args)
     end
  end
 
  def writeCase term,args
    addTxt espa+"when \:token_"+@dico.getTerminalNumber(term).to_s+""
    indent
    if @altCount>1
      @tmpAltern.returnObj[0].accept(self,args)
      @altCount -= 1
      @tmpAltern = @tmpAltern.returnObj[1]
    else
      @tmpAltern.accept(self,args) 
    end   
    desindent 
  end

  def ecritRhsaltRhs rhs,args=nil
    bool = false

    #check if there is already a dico of first terminal in the args
    bool,dico = rhs.getDicoTermAlt([],args) if !args.kind_of?(Array)
    bool,dico = true,args[1] if args.kind_of?(Array) 
    args=[args] if !args.kind_of?(Array) 
    args = [args[0],dico] if bool
   
    #=== AST ===
    args[0].placement =  args[0].placement.clone << "a"
    #==========

    tmp,name = rhs.altRhs[1].returnObjNam #to now if we need to keep a dico of first terminal in the args
    #=== AST ===
    args2 = args[0].clone
    args2.placement = args[0].placement.clone
    args2.placement = args[0].placement.chop if name=="altRhs"  
    #===========

    if bool && dico.include?(term = rhs.returnTerminal(args[0]).to_s) #if we can see a unique first terminal we prefere use a if statement than a "begin rescue"
      addTxt espa+"tmpStream#{@indent}=\@lexer\.stream\.clone\n"
      addTxt espa + "if showNext.kind \=\= \:token_#{@dico.getTerminalNumber(term).to_s}\n"
      indent
      rhs.altRhs[0].accept(self,args[0])
      if args[0].loopTerm!=nil && args[0].loopTerm!=[]
        addTxt espa+"if"+writeCondAlt(args[0].loopTerm)
        addTxt espa(2)+"set_Stream(tmpStream#{(@indent-1)})\n"
        addTxt espa+"else\n"
        addTxt espa(2)+"return #{args[0].name.first.downcase} \n"
        addTxt espa+"end\n"
      else
        addTxt espa+"return #{args[0].name.first.downcase}\n"
      end
      desindent
      addTxt espa + "end\n"
    else 
      addTxt espa+"tmpStream#{@indent}=\@lexer\.stream\.clone\n"
      addTxt espa+"begin\n"
      indent
      rhs.altRhs[0].accept(self,args[0])
      if args[0].loopTerm!=nil && args[0].loopTerm!=[]
        addTxt espa+"if"+writeCondAlt(args[0].loopTerm)
        writeCondAlt(args[0].loopTerm)
        addTxt espa(2)+"raise \"\"\n"
        addTxt espa+"end\n"
      end
      desindent
      addTxt "\n"+espa+"rescue\n"
      addTxt espa(2)+"set_Stream(tmpStream#{@indent})\n"
      addTxt espa+"else\n"
      addTxt espa(2)+"return #{args[0].name.first.downcase}\n" 
      addTxt espa+"end\n"
    end
    
    addTxt espa+args[0].name.first.downcase+" = "+args[0].name.first.upcase+"\.new\n"
    
    args[0] = args2
    
    args = args[0] if name!="altRhs" && args.kind_of?(Array)

    

    rhs.altRhs[1].accept(self,args)
  end
  
  def writeCondAlt listTerm
    @condition =" ["
    
    listTerm.each{|term| tmpFonc(term)}
    @condition = @condition.chop
    
    @condition << "].include?(showNext.kind) && checkNeeded\n"
  end

  def tmpFonc term
    @condition << "\:token_#{@dico.getTerminalNumber(term.to_s)}\,"
  end
  
  def ecritRhsconcRhs rhs,args=nil
    rhs2,name = rhs.concRhs[0].returnObjNam 
    #=== futur loop ====
    newargs=args
    if args.bool && args.advance==false #are we on the top altern ?
      newargs=args.clone 
      newargs.advance=true #work with clone because true isn't an object class ?
    end
    #===================  
    
    #=== AST ===  
    args.placement=args.placement.clone
    newargs.placement=args.placement.clone
    newargs2 = newargs
    newargs2.placement=newargs2.placement.clone
    #===========

    if name == "repRhs" ||name == "optRhs"
      rhs.concRhs[0].accept(self,[newargs,rhs.concRhs[1]])
    else
      rhs.concRhs[0].accept(self,args)
    end
    
    rhs.concRhs[1].accept(self,newargs2)
  end
end

