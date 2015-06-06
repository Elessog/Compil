require 'pp'
require_relative 'output_codewriting'

class Compiler

  def initialize
    puts "EBNF compiler".center(40,'=')
    @parser=Parser.new
  end

  def compile filename
    raise "usage error : EBNF file needed !" if not filename
    puts "==> compiling #{filename}"
    @ast = @parser.parse(filename)
    pp @ast
    #exit
    #simpleVisit
    #rewriteVisit
    #codewriteVisit
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
  end

end

compiler=Compiler.new
compiler.compile ARGV[0]
