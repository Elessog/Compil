require 'pp'
require_relative 'lexer'
require_relative 'output_astwriting'


TOKEN_DEF={
  :token_1	=> /class/,
  :token_2	=> /\{/,
  :token_3	=> /public/,
  :token_4	=> /static/,
  :token_5	=> /void/,
  :token_6	=> /main/,
  :token_7	=> /\(/,
  :token_8	=> /String/,
  :token_9	=> /\[/,
  :token_10	=> /\]/,
  :token_11	=> /\)/,
  :token_12	=> /\}/,
  :token_13	=> /extends/,
  :token_14	=> /implements/,
  :token_15	=> /int/,
  :token_16	=> /\;/,
  :token_17	=> /\,/,
  :token_18	=> /return/,
  :token_19	=> /boolean/,
  :token_20	=> /if/,
  :token_21	=> /else/,
  :token_22	=> /while/,
  :token_23	=> /System\.out\.println/,
  :token_24	=> /\=/,
  :token_25	=> /\./,
  :token_26	=> /\&\&/,
  :token_27	=> /\</,
  :token_28	=> /\>/,
  :token_29	=> /\+/,
  :token_30	=> /\-/,
  :token_31	=> /\*/,
  :token_32	=> /true/,
  :token_33	=> /false/,
  :token_34	=> /this/,
  :token_35	=> /new/,
  :token_36	=> /\!/,
  :token_37	=> /length/,
  :token_38	=> /EOF/,
  

# !!!! auto writting of the next kind of token, to be deleted or put in missing rule(s)
  :identifier	=> /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer	=> /[0-9]+/#,
  #:reste	=> /./
}

class Parser

  attr_accessor :lexer

  def initialize
    @lexer=Lexer.new(TOKEN_DEF)
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseModule()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      @last_error = "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos}"
      raise "expecting #{token_kind}. Got #{next_tok.kind} at #{next_tok.pos} \n\tparsing error"
    end
    return next_tok    
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @lexer.get_next
  end

  def add_first token #deprecated method
    @lexer.add_first(token)
  end

  def get_Stream #deprecated method
    @lexer.get_Stream
  end
  
  def set_Stream newStream
    @lexer.set_Stream(newStream)
  end
  
  #======= First Call ================= Write fisrt rule to be applied, in method parseModule
  
  def parseModule
    puts "start of parsing"
    ast = parseGoal #this is the last uncalled rule in the ast, first rule could be another
    puts "end"
    if get_Stream!=[] #printing of the last error if stream not finish due to use of begin and rescue we can not crash but still the file to be parse is not write correctly
       puts @last_error
       exit
    end 
    ast
  end

  #=======Specific to language=========

  def parseGoal
    goal = GOAL.new
    goal.mainclass_1 = parseMainClass
    continue_2 = false
    if showNext.kind== :token_1
      continue_2 = true
    end

    while continue_2
      goal.rclassdeclaration_1 << parseClassDeclaration
      if showNext.kind!= :token_1
        continue_2 = false
      end
    end
    goal.eof_1 = parseEOF
    goal

  end

  def parseMainClass
    mainclass = MAINCLASS.new

    expect :token_1
    mainclass.identifier_1 = parseIdentifier

    expect :token_2

    expect :token_3

    expect :token_4

    expect :token_5

    expect :token_6

    expect :token_7

    expect :token_8

    expect :token_9

    expect :token_10
    mainclass.identifier_2 = parseIdentifier

    expect :token_11

    expect :token_2
    mainclass.statement_1 = parseStatement

    expect :token_12

    expect :token_12
    mainclass

  end

  def parseClassDeclaration
    classdeclaration = CLASSDECLARATION.new

    expect :token_1
    classdeclaration.identifier_1 = parseIdentifier
    tmpClassDeclaration2=classdeclaration.clone
    tmpStream2=@lexer.stream.clone
    begin

      expect :token_13
      classdeclaration.oidentifier_1 = parseIdentifier

    rescue
      set_Stream(tmpStream2)
      classdeclaration=tmpClassDeclaration2
    end
    if showNext.kind != :token_2

      expect :token_14
      classdeclaration.oidentifier_2 = parseIdentifier
    end

    expect :token_2
    continue_2 = false
    if showNext.kind== :token_15
      continue_2 = true
    end

    while continue_2
      classdeclaration.rvardeclaration_1 << parseVarDeclaration
      if showNext.kind!= :token_15
        continue_2 = false
      end
    end
    continue_2 = false
    if showNext.kind!= :token_12
      continue_2 = true
    end

    while continue_2
      classdeclaration.rmethoddeclaration_1 << parseMethodDeclaration
      if showNext.kind== :token_12
        continue_2 = false
      end
    end

    expect :token_12
    classdeclaration

  end

  def parseVarDeclaration
    vardeclaration = VARDECLARATION.new
    vardeclaration.type_1 = parseType
    vardeclaration.identifier_1 = parseIdentifier

    expect :token_16
    vardeclaration

  end

  def parseMethodDeclaration
    methoddeclaration = METHODDECLARATION.new

    expect :token_3
    methoddeclaration.type_1 = parseType
    methoddeclaration.identifier_1 = parseIdentifier

    expect :token_7
    if showNext.kind != :token_11
      methoddeclaration.otype_1 = parseType
      methoddeclaration.oidentifier_1 = parseIdentifier
      continue_3 = false
      if showNext.kind== :token_17
        continue_3 = true
      end

      while continue_3

        expect :token_17
        methoddeclaration.ortype_1 << parseType
        methoddeclaration.oridentifier_1 << parseIdentifier
        if showNext.kind!= :token_17
          continue_3 = false
        end
      end
    end

    expect :token_11

    expect :token_2
    continue_2 = false
    if showNext.kind== :token_15
      continue_2 = true
    end

    while continue_2
      methoddeclaration.rvardeclaration_1 << parseVarDeclaration
      if showNext.kind!= :token_15
        continue_2 = false
      end
    end
    continue_2 = false
    if showNext.kind!= :token_18
      continue_2 = true
    end

    while continue_2
      methoddeclaration.rstatement_1 << parseStatement
      if showNext.kind== :token_18
        continue_2 = false
      end
    end

    expect :token_18
    methoddeclaration.expression_1 = parseExpression

    expect :token_16

    expect :token_12
    methoddeclaration

  end

  def parseType
    type = TYPE.new
    tmpStream2=@lexer.stream.clone
    begin

      expect :token_15

      expect :token_9

      expect :token_10

    rescue
      set_Stream(tmpStream2)
    else
      return type
    end
    type = TYPE.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_19

      expect :token_19
      return type
    end
    type = TYPE.new
    tmpStream2=@lexer.stream.clone
    begin

      expect :token_15

    rescue
      set_Stream(tmpStream2)
    else
      return type
    end
    type = TYPE.new
    type.agidentifier_1 = parseIdentifier
    type

  end

  def parseStatement
    statement = STATEMENT.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_2

      expect :token_2
      continue_3 = false
      if showNext.kind!= :token_12
        continue_3 = true
      end

      while continue_3
        statement.agrstatement_1 << parseStatement
        if showNext.kind== :token_12
          continue_3 = false
        end
      end

      expect :token_12
      return statement
    end
    statement = STATEMENT.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_20

      expect :token_20

      expect :token_7
      statement.agexpression_1 = parseExpression

      expect :token_11
      statement.agstatement_1 = parseStatement

      expect :token_21
      statement.agstatement_2 = parseStatement
      return statement
    end
    statement = STATEMENT.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_22

      expect :token_22

      expect :token_7
      statement.agexpression_2 = parseExpression

      expect :token_11
      statement.agstatement_3 = parseStatement
      return statement
    end
    statement = STATEMENT.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_23

      expect :token_23

      expect :token_7
      statement.agexpression_3 = parseExpression

      expect :token_11

      expect :token_16
      return statement
    end
    statement = STATEMENT.new
    tmpStream2=@lexer.stream.clone
    begin
      statement.agidentifier_1 = parseIdentifier

      expect :token_24
      statement.agexpression_4 = parseExpression

      expect :token_16

    rescue
      set_Stream(tmpStream2)
    else
      return statement
    end
    statement = STATEMENT.new
    statement.agidentifier_2 = parseIdentifier

    expect :token_9
    statement.agexpression_5 = parseExpression

    expect :token_10

    expect :token_24
    statement.agexpression_6 = parseExpression

    expect :token_16
    statement

  end

  def parseExpression checkNeeded = true
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin
      expression.agintegerliteral_1 = parseIntegerLiteral
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_32

      expect :token_32
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        set_Stream(tmpStream2)
      else
        return expression 
      end
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_33

      expect :token_33
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        set_Stream(tmpStream2)
      else
        return expression 
      end
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin
      expression.agidentifier_1 = parseIdentifier
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_34

      expect :token_34
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        set_Stream(tmpStream2)
      else
        return expression 
      end
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin

      expect :token_35

      expect :token_15

      expect :token_9
      expression.agexpression_1 = parseExpression

      expect :token_10
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin

      expect :token_35
      expression.agidentifier_2 = parseIdentifier

      expect :token_7

      expect :token_11
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_36

      expect :token_36
      expression.agexpression_2 = parseExpression
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        set_Stream(tmpStream2)
      else
        return expression 
      end
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    if showNext.kind == :token_7

      expect :token_7
      expression.agexpression_3 = parseExpression

      expect :token_11
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        set_Stream(tmpStream2)
      else
        return expression 
      end
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin
      expression.agexpression_4 = parseExpression false

      expect :token_9
      expression.agexpression_5 = parseExpression

      expect :token_10
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin
      expression.agexpression_6 = parseExpression false

      expect :token_25

      expect :token_37
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    tmpStream2=@lexer.stream.clone
    begin
      expression.agexpression_7 = parseExpression false

      expect :token_25
      expression.agidentifier_3 = parseIdentifier

      expect :token_7
      if showNext.kind != :token_11
        expression.agoexpression_1 = parseExpression
        continue_4 = false
        if showNext.kind== :token_17
          continue_4 = true
        end

        while continue_4

          expect :token_17
          expression.agorexpression_1 << parseExpression
          if showNext.kind!= :token_17
            continue_4 = false
          end
        end
      end

      expect :token_11
      if ( showNext.kind == :token_9|| showNext.kind == :token_25|| showNext.kind == :token_25|| showNext.kind == :token_26|| showNext.kind == :token_27|| showNext.kind == :token_28|| showNext.kind == :token_29|| showNext.kind == :token_30|| showNext.kind == :token_31) && checkNeeded
        raise ""
      end

    rescue
      set_Stream(tmpStream2)
    else
      return expression
    end
    expression = EXPRESSION.new
    expression.agexpression_8 = parseExpression false
    tmpKind = showNext.kind
    case tmpKind
      when :token_26
        expect :token_26
      when :token_27
        expect :token_27
      when :token_28
        expect :token_28
      when :token_29
        expect :token_29
      when :token_30
        expect :token_30
      when :token_31
        expect :token_31
    else
      raise "erreur"
    end
    expression.agexpression_9 = parseExpression
    expression

  end

  def parseEOF
    eof = EOF.new

    expect :token_38
    eof

  end



  #====== Missing Rules ======

  def parseIdentifier
    (expect :identifier).value
  end

  def parseIntegerLiteral
    (expect :integer).value
  end



end

