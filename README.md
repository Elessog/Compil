READ ME  COMPILATEUR EBNF
=========================

This code is a little project made for a compilator course


1°) Write an EBNF file
======================

  - identifier
  - "terminal"
  - [] for optionnal rule
  - {} multiple rule (0..*)
  - () groupement
  - , concatenation
  - | alternative
  - ; end of rule

**How to make a rule**

  example:

		IfStatement = ("if",{Statement},["else",{Statement}],"end");  

  If you call a rule (here Statement) you should make sure it exist, unless the call is about
  identifier and number
  
  If you want to make a rule about identifier and number , write it likewise (as a call not a rule by itself) on your ebnf file
  then when the output file is made , make sure to add:
     (expect :identifier).value in the parseIdentifier function
     (expect :digit).value in the parseNumber function

  You shouldn't write anything more or make sure to return the value of the token. 

  - There is no priority symbol between **"|"** and **","** so you should write groupement if needed

  - If you write a rule which call itself, there should be alternative statement and you should write each 
    statement in groupement

      example :

		Expression = (Identifier) |( Expression , "," , Expression);

    You must not write a rule such as :

		Expression = (Expression, "," , Expression )

    or
     
		Statement = Statement

    as the output programme will end up in a infinite loop
   
   If your Statement have the rule  calling itself first (in the | statement ) It should be write at the end of the alternative statements
       example: 

		Expression = (Identifier) | ( "(" , Expression , ")" ) | ( Expression , "," , Expression);



**Complete the EBNF file**

Normally the lexer will recognize any symbol (meaning there will be no reporting of error with the lexer), with you want
to change it delete in TOKEN_DEF in parser_etudiant.rb the "autre" regexp ( **/./**) and write the symbol needed as a regexp:

    example:

		:pound	=> /\£/,


2°) Run the compiler
====================

On the termimal write 'ruby compiler.rb filename'

The output files will be on the folder 'output':

                - output_codewriting.rb : the parser
                - output_astwriting.rb : the ast class
                - output_html.html : the ebnf rewritten with colour
                - output_rewrite.txt : the ebnf rewritten


**!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**

error of optimisation with optionnaland repetitive rule in ecritOptRhs and ecritRepRhs change condition in if statement to allow 
last code writing option (with the begin and rescue)

erreur d'optimisation sur les options et repetitions
dans le fonctions ecritOptRhs et ecritRepRhs sur les if où l'ont ecrit mettre les conditions des deux premiers statement a if
pour forcer l'ecriture du begin rescue



3°) Efficiency of the compiler
==============================

For analyse purposes it have been added in file a counter to record the position of the token in the stream.
The file **data_stream.data** is write by the first parser and by the output parser (in their respective folder). 
Then you can use the MATLAB script to easily plot the data 





