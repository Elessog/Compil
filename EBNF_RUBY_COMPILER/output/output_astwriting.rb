class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    visitor.send("visit#{name}".to_sym, self ,arg)
  end
end

#===========


class GOAL < Ast
    attr_accessor :mainclass_1,:eof_1,:rclassdeclaration_1
    def initialize mainclass_1=nil,eof_1=nil,rclassdeclaration_1=[]
      @mainclass_1=mainclass_1
      @eof_1=eof_1
      @rclassdeclaration_1=rclassdeclaration_1
      
    end
end



class MAINCLASS < Ast
    attr_accessor :identifier_1,:identifier_2,:statement_1
    def initialize identifier_1=nil,identifier_2=nil,statement_1=nil
      @identifier_1=identifier_1
      @identifier_2=identifier_2
      @statement_1=statement_1
      
    end
end



class CLASSDECLARATION < Ast
    attr_accessor :identifier_1,:oidentifier_1,:rvardeclaration_1,:rmethoddeclaration_1
    def initialize identifier_1=nil,oidentifier_1=nil,rvardeclaration_1=[],rmethoddeclaration_1=[]
      @identifier_1=identifier_1
      @oidentifier_1=oidentifier_1
      @rvardeclaration_1=rvardeclaration_1
      @rmethoddeclaration_1=rmethoddeclaration_1
      
    end
end



class VARDECLARATION < Ast
    attr_accessor :type_1,:identifier_1
    def initialize type_1=nil,identifier_1=nil
      @type_1=type_1
      @identifier_1=identifier_1
      
    end
end



class METHODDECLARATION < Ast
    attr_accessor :type_1,:identifier_1,:expression_1,:otype_1,:oidentifier_1,:ortype_1,:oridentifier_1,:rvardeclaration_1,:rstatement_1
    def initialize type_1=nil,identifier_1=nil,expression_1=nil,otype_1=nil,oidentifier_1=nil,ortype_1=[],oridentifier_1=[],rvardeclaration_1=[],rstatement_1=[]
      @type_1=type_1
      @identifier_1=identifier_1
      @expression_1=expression_1
      @otype_1=otype_1
      @oidentifier_1=oidentifier_1
      @ortype_1=ortype_1
      @oridentifier_1=oridentifier_1
      @rvardeclaration_1=rvardeclaration_1
      @rstatement_1=rstatement_1
      
    end
end



class TYPE < Ast
    attr_accessor :agidentifier_1
    def initialize agidentifier_1=nil
      @agidentifier_1=agidentifier_1
      
    end
end



class STATEMENT < Ast
    attr_accessor :agrstatement_1,:agexpression_1,:agstatement_1,:agstatement_2,:agexpression_2,:agstatement_3,:agexpression_3,:agidentifier_1,:agexpression_4,:agidentifier_2,:agexpression_5,:agexpression_6
    def initialize agrstatement_1=[],agexpression_1=nil,agstatement_1=nil,agstatement_2=nil,agexpression_2=nil,agstatement_3=nil,agexpression_3=nil,agidentifier_1=nil,agexpression_4=nil,agidentifier_2=nil,agexpression_5=nil,agexpression_6=nil
      @agrstatement_1=agrstatement_1
      @agexpression_1=agexpression_1
      @agstatement_1=agstatement_1
      @agstatement_2=agstatement_2
      @agexpression_2=agexpression_2
      @agstatement_3=agstatement_3
      @agexpression_3=agexpression_3
      @agidentifier_1=agidentifier_1
      @agexpression_4=agexpression_4
      @agidentifier_2=agidentifier_2
      @agexpression_5=agexpression_5
      @agexpression_6=agexpression_6
      
    end
end



class EXPRESSION < Ast
    attr_accessor :agintegerliteral_1,:agidentifier_1,:agexpression_1,:agidentifier_2,:agexpression_2,:agexpression_3,:agexpression_4,:agexpression_5,:agexpression_6,:agexpression_7,:agidentifier_3,:agexpression_8,:agexpression_9,:agoexpression_1,:agorexpression_1
    def initialize agintegerliteral_1=nil,agidentifier_1=nil,agexpression_1=nil,agidentifier_2=nil,agexpression_2=nil,agexpression_3=nil,agexpression_4=nil,agexpression_5=nil,agexpression_6=nil,agexpression_7=nil,agidentifier_3=nil,agexpression_8=nil,agexpression_9=nil,agoexpression_1=nil,agorexpression_1=[]
      @agintegerliteral_1=agintegerliteral_1
      @agidentifier_1=agidentifier_1
      @agexpression_1=agexpression_1
      @agidentifier_2=agidentifier_2
      @agexpression_2=agexpression_2
      @agexpression_3=agexpression_3
      @agexpression_4=agexpression_4
      @agexpression_5=agexpression_5
      @agexpression_6=agexpression_6
      @agexpression_7=agexpression_7
      @agidentifier_3=agidentifier_3
      @agexpression_8=agexpression_8
      @agexpression_9=agexpression_9
      @agoexpression_1=agoexpression_1
      @agorexpression_1=agorexpression_1
      
    end
end



