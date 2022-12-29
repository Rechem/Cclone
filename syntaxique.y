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
%token CONTINUE
%token BREAK

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
Declaration:
    DeclarationSimple
    | DeclarationVarableStructure
    ;
DeclarationSimple:
    SimpleType ID
    | List ID
    ;
DeclarationVarableStructure:
    ID ID COMA
    ;
Tableau:
    ACCOLADEOUVRANTE Tableau ComaLoopTableau ACCOLADEFERMANTE
    | ACCOLADEOUVRANTE Expression ComaLoopExpression ACCOLADEFERMANTE
    ;
ComaLoopTableau:
    COMA Tableau
    ;
ComaLoopExpression:
    COMA Expression
    ;

PureAffectation:
    EQUALS Expression
    | EQUALS Tableau
    | DOT PureAffectation
    ;
DeclarationInitialisation:
    DeclaraitonSimple PureAffectation
    | CONST DeclaraitonSimple PureAffectation
    ;
Affectation:
    Variable PureAffectation
    | Variable RapidAffectation
    ;
RapidAffectation:
    OperateurUnaire
    | ADDEQUALS Expression
    | SUBEQUALS Expression
    | MULEQUALS Expression
    | DIVEQUALS Expression
    | MODEQUALS Expression
    ;
Statement:
    Declaration SEMICOLUMN
    | AppelFonction SEMICOLUMN
    | Affectation SEMICOLUMN
    | Boucle
    | Condition
    | BREAK
    | CONTINUE
    | RETURN Expression SEMICOLUMN


%%
int yyerror(const char *s) {
  printf("%s\n",s);
}

int main (void)
{
    yyparse();
    return 0;
}




