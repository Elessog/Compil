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

  - There is no priority symbol between **|** and **,** so you should write groupement if needed

  - If you write a rule which call itself, there should be alternative statement and you should write each 
    statement in groupement
      example :
		Expression = (Identifier) |( Expression , "," , Expression);
    You must not write a rule such as :
		Expression = (Expression, "," , Expression )
    as the output programme will end up in a infinite loop
   
   If your Statement have the rule which call itself first (in the statement ) should be write at the end of the alternative statements
       example: 
		Expression = (Identifier) | ( "(" , Expression , ")" ) | ( Expression , "," , Expression);


**Complete the EBNF file**

As the compiler is not completly finish before running you should copy paste the next line (without the %%% ) in
the beginning of the file:

		letterDef = "A" | "B" | "C" | "D" | "E" | "F" | "G"
			| "H" | "I" | "J" | "K" | "L" | "M" | "N"
			| "O" | "P" | "Q" | "R" | "S" | "T" | "U"
			| "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d" | "e" | "f" | "g"
			| "h" | "i" | "j" | "k" | "l" | "m" | "n"
			| "o" | "p" | "q" | "r" | "s" | "t" | "u"
			| "v" | "w" | "x" | "y" | "z" ;
		digitDef = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
		symbolDef = "[" | "]" | "{" | "}" | "(" | ")" | "<" | ">"
			| "'" | """ | "=" | "|" | "." | "," | ";" | "&" | "*" | "&&";


Make sure the symbol you use are in the symbolDef line and in the hach TOKEN_DEF in the file parser_etudiant.rb especially if it use more than one character like && or <=.


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




