class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    visitor.send("visit#{name}".to_sym, self ,arg)
  end
end

#===========


class CHARACTER < Ast
    attr_accessor :agletter_1,:agdigit_1,:agsymbol_1
    def initialize agletter_1=nil,agdigit_1=nil,agsymbol_1=nil
      @agletter_1=agletter_1
      @agdigit_1=agdigit_1
      @agsymbol_1=agsymbol_1
      
    end
end



class ALPHANUM < Ast
    attr_accessor :agletter_1,:agdigit_1
    def initialize agletter_1=nil,agdigit_1=nil
      @agletter_1=agletter_1
      @agdigit_1=agdigit_1
      
    end
end



class IDENTIFIER < Ast
    attr_accessor :letter_1,:ralphanum_1
    def initialize letter_1=nil,ralphanum_1=[]
      @letter_1=letter_1
      @ralphanum_1=ralphanum_1
      
    end
end



class TERMINAL < Ast
    attr_accessor :agcharacter_1,:agcharacter_2,:agrcharacter_1,:agrcharacter_2
    def initialize agcharacter_1=nil,agcharacter_2=nil,agrcharacter_1=[],agrcharacter_2=[]
      @agcharacter_1=agcharacter_1
      @agcharacter_2=agcharacter_2
      @agrcharacter_1=agrcharacter_1
      @agrcharacter_2=agrcharacter_2
      
    end
end



class LHS < Ast
    attr_accessor :identifier_1
    def initialize identifier_1=nil
      @identifier_1=identifier_1
      
    end
end



class RHS < Ast
    attr_accessor :agidentifier_1,:agterminal_1,:agrhs_1,:agrhs_2,:agrhs_3,:agrhs_4,:agrhs_5,:agrhs_6,:agrhs_7
    def initialize agidentifier_1=nil,agterminal_1=nil,agrhs_1=nil,agrhs_2=nil,agrhs_3=nil,agrhs_4=nil,agrhs_5=nil,agrhs_6=nil,agrhs_7=nil
      @agidentifier_1=agidentifier_1
      @agterminal_1=agterminal_1
      @agrhs_1=agrhs_1
      @agrhs_2=agrhs_2
      @agrhs_3=agrhs_3
      @agrhs_4=agrhs_4
      @agrhs_5=agrhs_5
      @agrhs_6=agrhs_6
      @agrhs_7=agrhs_7
      
    end
end



class RULE < Ast
    attr_accessor :lhs_1,:rhs_1
    def initialize lhs_1=nil,rhs_1=nil
      @lhs_1=lhs_1
      @rhs_1=rhs_1
      
    end
end



class GRAMMAR < Ast
    attr_accessor :rrule_1
    def initialize rrule_1=[]
      @rrule_1=rrule_1
      
    end
end



