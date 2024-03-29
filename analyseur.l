%{
#include <stdbool.h>
#include "syntaxique.tab.h"


extern void yysuccess(char *s);
extern void yyerror(const char *s);
extern void showLexicalError();
extern int currentColumn;

%}

%option yylineno 
%option noyywrap 

FLOAT               ([0-9]*\.[0-9]+)([eE][+-]?[0-9])?
INT                 [0-9]+([eE][+-]?[0-9])?
STRING               \".*\"
BOOL                (true|false)

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

LINEBREAK "\n"|"\r"
COMMENTLINE         "//".*
COMMENTTEXT         [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]

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
NOTEQUALS "!="
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

{CONST} {
    yysuccess("CONST");
    yylval.isConstant = true;
    return CONST;
}
{INTTYPE} {
    yysuccess("INT TYPE");
    yylval.type = TYPE_INTEGER;
    return INTTYPE;
}
{STRINGTYPE} {
    yysuccess("STRING TYPE");
    yylval.type = TYPE_STRING;
    return STRINGTYPE;
}
{FLOATTYPE} {
    yysuccess("FLOAT TYPE");
    yylval.type = TYPE_FLOAT;
    return FLOATTYPE;
}
{BOOLTYPE} {
    yysuccess("BOOLEAN TYPE");
    yylval.type = TYPE_BOOLEAN;
    return BOOLTYPE;
}
{LIST} {
    // we dont know about you yet okay ?
    yysuccess("LIST");
    return LIST;
}
{TYPE} {
    yysuccess("TYPE");
    return TYPE;
}
{IF} {
    yysuccess("IF");
    return IF;
}
{ELSE} {
    yysuccess("ELSE");
    return ELSE;
}
{WHILE} {
    yysuccess("WHILE");
    return WHILE;
}
{FOR} {
    yysuccess("FOR");
    return FOR;
}
{IN} {
    yysuccess("IN");
    return IN;
}
{RETURN} {
    yysuccess("RETURN");
    return RETURN;
}


{FLOAT}  {
    yysuccess("FLOAT");
    yylval.floatValue = strtod(yytext, NULL);
    return FLOAT;
}
{INT}    {
    yysuccess("INT");
    yylval.integerValue = atoi(yytext);
    return INT;
}

{BOOL}    {
    yysuccess("BOOLEAN");
    if(!strcmp(yytext, "true")){
        yylval.booleanValue = true;
    }else{
        yylval.booleanValue = false;
    }
    return BOOL;
}
{STRING}  {
    yysuccess("STRING");
    strcpy(yylval.stringValue, yytext);
    return STRING;
}


{PARENTHESEOUVRANTE}  {
    yysuccess("PARENTHESEOUVRANTE");
    return PARENTHESEOUVRANTE;
} 
{PARENTHESEFERMANTE}  {
    yysuccess("PARENTHESEFERMANTE");
    return PARENTHESEFERMANTE;
} 
{ACCOLADEOUVRANTE}  {
    yysuccess("ACCOLADEOUVRANTE");
    return ACCOLADEOUVRANTE;
} 
{ACCOLADEFERMANTE}  {
    yysuccess("ACCOLADEFERMANTE");
    return ACCOLADEFERMANTE;
} 
{CROCHETOUVRANT}  {
    yysuccess("CROCHETOUVRANT");
    return CROCHETOUVRANT;
} 
{CROCHETFERMANT}  {
    yysuccess("CROCHETFERMANT");
    return CROCHETFERMANT;
}
{SEMICOLUMN} {
    yysuccess("SEMICOLUMN");
    return SEMICOLUMN;
}
{COLUMN} {
    yysuccess("COLUMN");
    return COLUMN;
} 
{DOT} {
    yysuccess("DOT");
    return DOT;
}
{COMA} {
    yysuccess("LOOP");
    return COMA;
} 

{EQUALS}     {
    yysuccess("EQUALS");
    return EQUALS;
}
{ADD}     {
    yysuccess("ADD");
    return ADD;
}
{SUB}     {
    yysuccess("SUB");
    return SUB;
}
{MUL}     {
    yysuccess("MUL");
    return MUL;
}
{MOD}     {
    yysuccess("MOD");
    return MOD;
}
{DIV}     {
    yysuccess("DIV");
    return DIV;
}
{POW}     {
    yysuccess("POW");
    return POW;
}
{INC}     {
    yysuccess("INC");
    return INC;
}
{DEC}     {
    yysuccess("DEC");
    return DEC;
}
{NOTEQUALS}     {
    yysuccess("NOTEQUALS");
    return NOTEQUALS;
}
{ADDEQUALS}     {
    yysuccess("ADDEQUALS");
    return ADDEQUALS;
}
{SUBEQUALS}     {
    yysuccess("SUBEQUALS");
    return SUBEQUALS;
}
{MULEQUALS}     {
    yysuccess("MULEQUALS");
    return MULEQUALS;
}
{DIVEQUALS}     {
    yysuccess("DIVEQUALS");
    return DIVEQUALS;
}
{MODEQUALS}     {
    yysuccess("MODEQUALS");
    return MODEQUALS;
}
{NEG}     {
    yysuccess("NEG");
    return NEG;
}
{LESS}     {
    yysuccess("LESS");
    return LESS;
}
{LESSEQUALS}     {
    yysuccess("LESSEQUALS");
    return LESSEQUALS;
}
{GREATER}     {
    yysuccess("GREATER");
    return GREATER;
}
{GREATEREQUALS}     {
    yysuccess("GREATEREQUALS");
    return GREATEREQUALS;
}
{DOUBLEEQUALS}     {
    yysuccess("DOUBLEEQUALS");
    return DOUBLEEQUALS;
}
{AND}     {
    yysuccess("AND");
    return AND;
}
{OR}     {
    yysuccess("OR");
    return OR;
}

{ID} {
    yysuccess("ID");
    strcpy(yylval.identifier, yytext);
    return ID;
}

{LINEBREAK} {
    currentColumn =1;
}

[ \t]+ {
    currentColumn+=yyleng;
}

{COMMENTLINE} {}
{COMMENTTEXT} {}

<<EOF>> yyterminate();

. {
    yyerror("Unexpected token");
    showLexicalError();
    yyterminate();
    }

%%
