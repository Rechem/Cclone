%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int yylex();
int yyerror(const char *s);
%}

// les terminaux only
%token IMPORT
%token FUN
%token CONST
%token INTTYPE
%token STRINGTYPE
%token FLOATTYPE
%token BOOLTYPE
%token LIST
%token TYPE
%token IF
%token ELSE
%token WHILE
%token FOR
%token IN
%token RETURN

%token ID

%token INT
%token STRING
%token BOOL
%token FLOAT

%token SEMICOLUMN
%token COLUMN
%token DOT
%token COMA

%token PARENTHESEOUVRANTE
%token PARENTHESEFERMANTE
%token ACCOLADEOUVRANTE
%token ACCOLADEFERMANTE

%token CROCHETOUVRANT
%token CROCHETFERMANT

%token EQUALS
%token ADD
%token SUB
%token MUL
%token MOD
%token DIV
%token POW
%token INC
%token DEC
%token ADDEQUALS
%token SUBEQUALS
%token MULEQUALS
%token DIVEQUALS
%token MODEQUALS
%token NEG
%token LESS
%token LESSEQUALS
%token GREATER
%token GREATEREQUALS
%token DOUBLEEQUALS
%token AND
%token OR

%start ProgrammePrincipal
%%

ProgrammePrincipal:
    
    | Importation
    | Fonction
    ;

Importation:
    
    | IMPORT STRING SEMICOLUMN
    | Importation
    | Fonction
    ;

Fonction:
    FUN ID PARENTHESEOUVRANTE PARENTHESEFERMANTE FonctionReturnType ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

FonctionReturnType:
    COLUMN INTTYPE 
    ;

Bloc:
    RETURN INT SEMICOLUMN
    ;
%%
int yyerror(const char *s) {
  printf("%s\n",s);
}

int main (void)
{
    yyparse();
    return 0;
}




