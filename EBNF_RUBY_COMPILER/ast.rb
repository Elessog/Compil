require_relative 'codewriting'

class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    visitor.send("visit#{name}".to_sym, self ,arg)
  end
end

#===========

class Modul < Ast
    attr_accessor :grammar
    def initialize grammar=nil
      @grammar = grammar
    end
end

class Grammar < Ast
    attr_accessor :rule
    def initialize rule=[]
        @rule = rule
    end

    def getRule name
       n = @rule.find_index{|rule| rule.isRuleName(name)}
       return n if n==nil
       @rule.fetch(n)
    end
       
end


class Rule < Ast
    attr_accessor :lhs,:rhs
    def initialize lhs=nil, rhs=nil
        @lhs,@rhs=lhs,rhs
    end
    
    def isRuleName name
       return lhs.ident.to_s==name
    end
end

class Lhs < Ast
   attr_accessor :ident
   def initialize ident=nil
     @ident=ident
   end
end 

class Rhs  < Ast #this classe get more method for a better writing of the parser
  attr_accessor :ident,:terminal,:optRhs,:repRhs,:groupRhs,:altRhs,:concRhs
  def initialize ident=nil,terminal=nil,optRhs=nil,repRhs=nil,groupRhs=nil,altRhs=[],concRhs=[]
    @ident,@terminal,@optRhs,@repRhs,@groupRhs,@altRhs,@concRhs=ident,terminal,optRhs,repRhs,groupRhs,altRhs,concRhs
  end
  def returnObj #return non nil objet in instanciable variable of the object
     if @ident!=nil
        return @ident
     elsif @terminal!=nil
        return @terminal
     elsif @optRhs!=nil
        return @optRhs
     elsif @repRhs!=nil
        return @repRhs
     elsif @groupRhs!=nil
        return @groupRhs
     elsif @altRhs!=[]
        return @altRhs
     else
        return @concRhs
     end
  end
  
  def returnObjNam #return non nil objet in instanciable variable of the object and the name of the instance
     if @ident!=nil
        return @ident,"ident"
     elsif @terminal!=nil
        return @terminal,"terminal"
     elsif @optRhs!=nil
        return @optRhs,"optRhs"
     elsif @repRhs!=nil
        return @repRhs,"repRhs"
     elsif @groupRhs!=nil
        return @groupRhs,"groupRhs"
     elsif @altRhs!=[]
        return @altRhs,"altRhs"
     else
        return @concRhs,"concRhs"
     end
  end
 
  def isTerminal #check if non nil variable is a terminal
    tmp,name=self.returnObjNam
    return true if name == "terminal"
    return false 
  end

  def returnTerminal nameRule,n=0 #return a terminal if it exist
    nextObj,name = self.returnObjNam
    if name == "ident"
      nameRule1 = nameRule.clone
      nameRule1.name=nameRule1.name.clone
      if nameRule1.name.include?(nextObj.to_s) || nameRule1.ast.getRule(nextObj.to_s)== nil #loop and unwrited rule detector
        return nil
      else 
        nameRule1.name << nextObj.to_s 
        return nameRule1.ast.getRule(nextObj.to_s).rhs.returnTerminal(nameRule1,1)
      end
    elsif name =="terminal"
      return nextObj
    elsif !nextObj.kind_of?(Array)
      return nil if (name=="optRhs" || name=="repRhs") && n!=0 
      return nextObj.returnTerminal(nameRule,1)
    else
      return nextObj[0].returnTerminal(nameRule,1)
    end
  end

  def  isOnlyTerminal dico,nameRule,n=0 #return true if first rule of altern statements is terminal and return the list of terminal
    nextObj,name = self.returnObjNam

    return false,dico if (name=="optRhs" || name=="repRhs" )&& n!=0# optionnal staement is excluded as it could be buggy after but only after first call
    
    if name == "altRhs"
      bool,dico = nextObj[0].isOnlyTerminal(dico,nameRule,1)
      bool2,dico = nextObj[1].isOnlyTerminal(dico,nameRule,1)#recursive
      return bool & bool2 ,dico
    else
      term = nil
      if !nextObj.kind_of?(Array)
        if nextObj.kind_of?(Identifier)
################
          nameRule1 = nameRule.clone
          nameRule1.name=nameRule1.name.clone
          if nameRule1.name.include?(nextObj.to_s) || nameRule1.ast.getRule(nextObj.to_s)== nil #loop and unwrited rule detector
            return false,dico
          else 
            nameRule1.name << nextObj.to_s 
            return nameRule1.ast.getRule(nextObj.to_s).rhs.isOnlyTerminal(dico,nameRule1,1)#go in the rule called by identifier
          end
        end
#############
        if nextObj.kind_of?(Terminal)
          return true, dico << nextObj.to_s if !dico.include?(nextObj.to_s)
          return false,dico
        end
        return nextObj.isOnlyTerminal(dico,nameRule,1)
      else
        return nextObj[0].isOnlyTerminal(dico,nameRule,1)
      end
    end
  end

  def getDicoTerm dico,nameRule #return list of terminal if there are the first statement in altern statements
    nextObj,name = self.returnObjNam

    return true,dico if name=="optRhs"# optionnal staement is excluded as it could be buggy after    

    if name == "altRhs"
      term = nil
      dico << term.to_s if (term = nextObj[0].returnTerminal(nameRule)) != nil      
      return nextObj[1].getDicoTerm(dico,nameRule)
    else
      term = nil
      if !nextObj.kind_of?(Array)
        if nextObj.kind_of?(Identifier)
          term = self.returnTerminal(nameRule)
          return true ,dico if term == nil
          dico << term.to_s
          return true,dico
        end
        if nextObj.kind_of?(Terminal)
          return true,(dico << nextObj.to_s)
        end
        term = nextObj.returnTerminal(nameRule)
        return true ,dico if term == nil
        dico << term.to_s
        return true,dico
      else
        term = nextObj[0].returnTerminal(nameRule)
        return true,dico if (term) == nil
        dico << term.to_s
        return true,dico
      end
    end
  end

  def  getDicoTermAlt dico,nameRule #return list of terminal if there are the first statement in altern statements and there unique
    bool,dico = self.getDicoTerm([],nameRule)
    
    @aloneDico = dico.clone
    dico.each{ |decl| deleteRepet(decl,dico)}
    boll = true
    bool = false if dico==[]
    return bool, @aloneDico
  end
  
  def deleteRepet term,dico
    @aloneDico.delete(term) if dico.count(term)>1
  end
  
  def isThereAlt #check if there is an altern statement in the remaining ast 
     if self.altRhs!=[]
       return true
     elsif self.concRhs!=[]
       return (self.concRhs[0].isThereAlt || self.concRhs[1].isThereAlt)
     elsif self.returnObj.respond_to? :isThereAlt
       return self.returnObj.isThereAlt
     else
       return false
     end
  end
  
end

class Terminal  < Ast
    attr_accessor :character
    def initialize character=[]
        @character=character
    end
    def to_s
      sA=[]
      @character.each{|decl| sA << decl.to_s}
      sA.join
    end
end

class Identifier < Ast
    attr_accessor :letter,:alphaNum
    def initialize letter=nil,alphaNum=[]
        @letter=letter
        @alphaNum=alphaNum
    end

    def to_s
      sA=[@letter.to_s]
      @alphaNum.each{|decl| sA << decl.to_s}
      sA.join
    end
end

class AlphaNum < Ast
  attr_accessor :letter,:digit,:under
  def initialize letter=nil,digit=nil,under=nil
    @letter=letter
    @digit = digit
    @under=under
  end
  def returnObj
     if @letter!=nil
        return @letter
     elsif @digit!=nil
        return @digit
     else
        return @under
     end
  end

  def to_s
    self.returnObj.to_s
  end
end


class Character < Ast
  attr_accessor :letter,:digit,:under,:symbol
  def initialize letter=nil,digit=nil,symbol=nil,under=nil
    @letter=letter
    @digit = digit
    @symbol = symbol
    @under=under
  end
  def returnObj
     if @letter!=nil
        return @letter
     elsif @digit!=nil
        return @digit
     elsif @symbol!=nil
        return @symbol
     else
        return @under
     end
  end

  def to_s
    self.returnObj.to_s
  end
end


class Letter < Ast
    attr_accessor :letter
    def initialize letter=nil
        @letter = letter
    end
    
    def to_s
        @letter.to_s
    end
end
    
class Digit < Ast
    attr_accessor :digit
    def initialize digit=nil
        @digit = digit
    end

    def to_s
        @digit.to_s
    end
end

class Symbol_ < Ast
    attr_accessor :symbol
    def initialize symbol=nil
        @symbol = symbol
    end

    def to_s
        @symbol.to_s
    end
end 

