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
List :
    LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT DimensionLoop
    | LIST NOMSTRUCTURE CROCHETOUVRANT Expression CROCHETFERMANT DimensionLoop
    ;
DimensionLoop :
    
    | CROCHETOUVRANT Expression CROCHETOUVRANT
    ;
ReturnType :
    SimpleType
    | LIST SimpleType CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | LIST NOMSTRUCTURE CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | NOMSTRUCTURE
    ;
CrochetLoop :

    | CROCHETOUVRANT CROCHETFERMANT
    ;

OperateurBin :
    ADD | SUB | MUL | MOD | DIV | POW | LESS | LESSEQUALS | GREATER | GREATEREQUALS | EQUALS | AND | OR
    ;
OperateurUni :
    INC | DEC
    ;
ComplexType :
    List
    | NOMSTRUCTURE
    ;
Type :
    SimpleType
    | ComplexType
    ;
ConditionIF :
    IF PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE ConditionELSE
    ;
ConditionELSE :

    | ELSE ConditionIF 
    | ELSE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;
While :
    WHILE PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Valeur :
    INT | DEC | STRING | BOOL
    ;

For : 
    FOR PARENTHESEOUVRANTE Declaration_init SEMICOLUMN Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN Tableau PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN ID PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Boucle :
    While | For
    ;

Appel_fonction :
    ID PARENTHESEOUVRANTE Arguments PARENTHESEFERMANTE
    | ID PARENTHESEOUVRANTE PARENTHESEFERMANTE
    ;

Variable :
    ID
    | ID DOT Champ
    | ID CROCHETOUVRANT Expression CROCHETFERMANT
    | Appel_fonction
    ;

Champ :
    ID
    | ID DOT Champ
    ;

Arguments :
    Expression
    | Expression DOT Arguments
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




