require 'pp'
require_relative 'parser_etudiant'
require_relative 'visitor'
require_relative 'Rewrite'
require_relative 'codewriting'
require_relative 'astwriting'
require_relative 'htmlwriting'

class Compiler

  def initialize
    puts "EBNF compiler".center(40,'=')
    @parser=Parser.new
    @missingRules=[]
    @uncalledRules=[]
  end

  def compile filename
    tt="test"
    raise "usage error : EBNF file needed !" if not filename
    puts "==> compiling #{filename}"
    @ast=@parser.parse(filename)
    #pp @ast
    #exit
    #simpleVisit
    rewriteVisit
    astwriteVisit
    codewriteVisit 
    htmlwriteVisit filename
  end
 
  def simpleVisit
    visitor=Visitor.new false
    visitor.doIt(@ast)
  end

  def rewriteVisit
    rewrite=Rewriter.new false
    rewrite.doIt(@ast)
  end
  
  def codewriteVisit
    codewrite=CodeWriting.new false
    codewrite.doIt(@ast)
    @missingRules=codewrite.missingRules
    @uncalledRules=codewrite.uncalledRule
  end

  def astwriteVisit
    astwrite=AstWriting.new false
    astwrite.doIt(@ast)
  end

  def htmlwriteVisit filename=""
    htmlwrite=HtmlWriting.new(false,filename,@missingRules,@uncalledRules)
    htmlwrite.doIt(@ast)
  end

end

compiler=Compiler.new
compiler.compile ARGV[0]
