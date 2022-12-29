%{
#include <stdio.h>
#include "syntaxique.tab.h"
%}



WHITESPACE          [[:space:]]+

FLOAT               [+-]?([0-9]*\.[0-9]+)([eE][+-]?[0-9])?
INT                 [+-]?[0-9]+([eE][+-]?[0-9])?
STRING               \".*\"
BOOL                (true|false)


IMPORT import
FUN fun
CONST const
INTTYPE int
STRINGTYPE str
FLOATTYPE float
BOOLTYPE bool
LIST List
TYPE Type
IF if
ELSE else
WHILE while
FOR for
IN in
RETURN return

PARENTHESEOUVRANTE "("
PARENTHESEFERMANTE ")"
ACCOLADEOUVRANTE "{"
ACCOLADEFERMANTE "}"
CROCHETOUVRANT "["
CROCHETFERMANT "]"
SEMICOLUMN ";"
COLUMN ":"
DOT "."
COMA ","

EQUALS "="
ADD "+"
SUB "-"
MUL "*"
MOD "%"
DIV "/"
POW "**"
INC "++"
DEC "--"
ADDEQUALS "+="
SUBEQUALS "-="
MULEQUALS "*="
DIVEQUALS "/="
MODEQUALS "%="
NEG "!"
LESS "<"
LESSEQUALS "<="
GREATER ">"
GREATEREQUALS ">="
DOUBLEEQUALS "=="
AND "&&"
OR "||"

ID                  [A-Za-z_][A-Za-z0-9_]* 

%%

{IMPORT} return(IMPORT);
{FUN} return(FUN);
{CONST} return(CONST);
{INTTYPE} return(INTTYPE);
{STRINGTYPE} return(STRINGTYPE);
{FLOATTYPE} return(FLOATTYPE);
{BOOLTYPE} return(BOOLTYPE);
{LIST} return(LIST);
{TYPE} return(TYPE);
{IF} return(IF);
{ELSE} return(ELSE);
{WHILE} return(WHILE);
{FOR} return(FOR);
{IN} return(IN);
{RETURN} return(RETURN);



{FLOAT}                                   return(FLOAT);
{INT}                                     return(INT);
{BOOL}                                    return(BOOL);
{STRING}                                  return(STRING);


{PARENTHESEOUVRANTE}  return(PARENTHESEOUVRANTE); 
{PARENTHESEFERMANTE}  return(PARENTHESEFERMANTE); 
{ACCOLADEOUVRANTE}  return(ACCOLADEOUVRANTE); 
{ACCOLADEFERMANTE}  return(ACCOLADEFERMANTE); 
{CROCHETOUVRANT}  return(CROCHETOUVRANT); 
{CROCHETFERMANT}  return(CROCHETFERMANT);
{SEMICOLUMN} return(SEMICOLUMN);
{COLUMN} return(COLUMN); 
{DOT} return(DOT);
{COMA} return(COMA); 

{EQUALS}     return(EQUALS);
{ADD}     return(ADD);
{SUB}     return(SUB);
{MUL}     return(MUL);
{MOD}     return(MOD);
{DIV}     return(DIV);
{POW}     return(POW);
{INC}     return(INC);
{DEC}     return(DEC);
{ADDEQUALS}     return(ADDEQUALS);
{SUBEQUALS}     return(SUBEQUALS);
{MULEQUALS}     return(MULEQUALS);
{DIVEQUALS}     return(DIVEQUALS);
{MODEQUALS}     return(MODEQUALS);
{NEG}     return(NEG);
{LESS}     return(LESS);
{LESSEQUALS}     return(LESSEQUALS);
{GREATER}     return(GREATER);
{GREATEREQUALS}     return(GREATEREQUALS);
{DOUBLEEQUALS}     return(DOUBLEEQUALS);
{AND}     return(AND);
{OR}     return(OR);

{ID}     return(ID);

{WHITESPACE}                            {/* ignore */}
.                                       {printf("unexpected token (lexem non reconnu): '%s'\n", yytext);}

%%

int yywrap(void)
{
    return 1;
}