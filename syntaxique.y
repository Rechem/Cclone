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
    FUN ID PARENTHESEOUVRANTE Parametres PARENTHESEFERMANTE FonctionReturnType ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Parametres:

    | ReturnType ID Parametre
    ;

Parametre:

    | COMA ReturnType ID Parametre
    ;

FonctionReturnType:
    COLUMN ReturnType 
    ;

Bloc:
    
    | Statement Bloc
    ;

DeclarationStructure:
    TYPE ID COLUMN ACCOLADEOUVRANTE Declaration DeclarationLoopDeclarationStructure ACCOLADEFERMANTE
    ;

DeclarationLoopDeclarationStructure:
    SEMICOLUMN Declaration
    ;

SimpleType:
    INTTYPE
    | FLOATTYPE
    | STRINGTYPE
    | BOOLTYPE

Expression:
    PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE
    | NEG Expression
    | SUB Expression
    | ADD Expression
    | Expression OperateurBinaire Expression
    | Valeur
    | Variable

OperateurBinaire:
    EQUALS
    | ADD
    | SUB
    | MUL
    | MOD
    | DIV
    | POW
    | INC
    | DEC
    | ADDEQUALS
    | SUBEQUALS
    | MULEQUALS
    | DIVEQUALS
    | MODEQUALS
    | LESS
    | LESSEQUALS
    | GREATER
    | GREATEREQUALS
    | DOUBLEEQUALS
    | AND
    | OR
    
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
    | LIST ID CROCHETOUVRANT Expression CROCHETFERMANT DimensionLoop
    ;
DimensionLoop :
    
    | CROCHETOUVRANT Expression CROCHETOUVRANT
    ;
ReturnType :
    SimpleType
    | LIST SimpleType CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | LIST ID CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | ID
    ;
CrochetLoop :

    | CROCHETOUVRANT CROCHETFERMANT
    ;

OperateurUni :
    INC | DEC
    ;
ComplexType :
    List
    | ID
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
    INT | FLOAT | STRING | BOOL
    ;

For : 
    FOR PARENTHESEOUVRANTE DeclarationInitialisation SEMICOLUMN Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN Tableau PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN ID PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Boucle :
    While | For
    ;

AppelFonction :
    ID PARENTHESEOUVRANTE Arguments PARENTHESEFERMANTE
    | ID PARENTHESEOUVRANTE PARENTHESEFERMANTE
    ;

Variable :
    ID
    | ID DOT Champ
    | ID CROCHETOUVRANT Expression CROCHETFERMANT
    | AppelFonction
    ;

Champ :
    ID
    | ID COMA Champ
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




