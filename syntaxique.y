%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define YYDEBUG 1

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
%token NOTEQUALS
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

%left COMA
%left OR
%left AND
%left NEG

%nonassoc EQUALS LESS GREATER LESSEQUALS GREATEREQUALS
%nonassoc NOTEQUALS ADDEQUALS SUBEQUALS MULEQUALS DIVEQUALS MODEQUALS
%left ADD SUB
%left MULT DIV MOD

%nonassoc ADDRESSVALUE POINTERVALUE
%left DOT OPENBRACKET CLOSEBRACKET
%left POWER
%left OPENPARENTHESIS

%start ProgrammePrincipal
%%

ProgrammePrincipal: %empty
    | Importation
    ;

Importation: %empty
    | IMPORT STRING SEMICOLUMN Importation Fonction {printf("import statement\n");}
    ;

Fonction: %empty
    | FUN ID PARENTHESEOUVRANTE Parametres PARENTHESEFERMANTE FonctionReturnType ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE Fonction {printf("function statement\n");}
    ;

Parametres: %empty
    | ReturnType ID Parametre
    ;

Parametre: %empty
    | COMA ReturnType ID Parametre
    ;

FonctionReturnType: %empty
    | COLUMN ReturnType 
    ;

Bloc: %empty
    | Statement Bloc
    ;

DeclarationStructure:
    TYPE ID COLUMN ACCOLADEOUVRANTE Declaration DeclarationLoopDeclarationStructure ACCOLADEFERMANTE
    ;

DeclarationLoopDeclarationStructure: %empty
    | SEMICOLUMN Declaration
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
    
DeclarationInitialisation:
    DeclarationSimple PureAffectation
    | CONST DeclarationSimple PureAffectation
    ;

DeclarationSimple:
    SimpleType ID
    | List ID
    ;

Declaration:
    DeclarationSimple
    | DeclarationVarableStructure
    ;

DeclarationVarableStructure:
    ID ID
    ;
Tableau:
    ACCOLADEOUVRANTE Tableau ComaLoopTableau ACCOLADEFERMANTE
    | ACCOLADEOUVRANTE Expression ComaLoopExpression ACCOLADEFERMANTE
    ;
ComaLoopTableau: %empty
    | COMA Tableau
    ;
ComaLoopExpression: %empty
    | COMA Expression
    ;

PureAffectation:
    EQUALS Expression
    | EQUALS Tableau
    | DOT PureAffectation
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
    DeclarationInitialisation SEMICOLUMN
    | DeclarationStructure SEMICOLUMN
    | Declaration SEMICOLUMN
    | AppelFonction SEMICOLUMN
    | Affectation SEMICOLUMN
    | Boucle
    | Condition
    | BREAK SEMICOLUMN
    | CONTINUE SEMICOLUMN
    | RETURN SEMICOLUMN
    | RETURN Expression SEMICOLUMN
    ;

List:
    LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT DimensionLoop
    | LIST ID CROCHETOUVRANT Expression CROCHETFERMANT DimensionLoop
    ;
DimensionLoop: %empty
    | CROCHETOUVRANT Expression CROCHETOUVRANT
    ;
ReturnType:
    SimpleType
    | LIST SimpleType CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | LIST ID CROCHETOUVRANT CROCHETFERMANT CrochetLoop
    | ID
    ;
CrochetLoop: %empty
    | CROCHETOUVRANT CROCHETFERMANT
    ;

OperateurUnaire:
    INC
    | DEC
    ;
ComplexType:
    List
    | ID
    ;
Type:
    SimpleType
    | ComplexType
    ;
Condition:
    IF PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE ConditionELSE
    ;
ConditionELSE: %empty
    | ELSE Condition 
    | ELSE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;
While:
    WHILE PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Valeur:
    INT
    | FLOAT
    | STRING
    | BOOL
    ;

For: 
    FOR PARENTHESEOUVRANTE DeclarationInitialisation SEMICOLUMN Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN Tableau PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    | FOR PARENTHESEOUVRANTE Declaration IN Variable PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Boucle:
    While
    | For
    ;

AppelFonction:
    ID PARENTHESEOUVRANTE Arguments PARENTHESEFERMANTE
    | ID PARENTHESEOUVRANTE PARENTHESEFERMANTE
    ;

Variable:
    ID
    | ID DOT Variable
    | ID CROCHETOUVRANT Expression CROCHETFERMANT
    | AppelFonction
    ;

Arguments:
    Expression
    | Expression COMA Arguments
    ;

%%
int yyerror(const char *s) {
  printf("%s\n",s);
}

int main (void)
{
    yydebug = 1;
    extern FILE *yyin;
    yyin=fopen("prg.txt", "r");
    if(yyin==NULL){
        printf("erreur dans l'ouverture du fichier");
        return 1;
    }
    yyparse();  

printf("succ\n");

    return 0;
}




