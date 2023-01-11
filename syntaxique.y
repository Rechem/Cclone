%define parse.error verbose

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define YYDEBUG 1


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

%left DOT CROCHETOUVRANT CROCHETFERMANT
%left POW
%left PARENTHESEOUVRANTE

%start Bloc
%{
extern FILE *yyin;
extern int yylineno;
extern int yyleng;
extern int yylex();

char* file = "prg.txt";

int currentColumn = 1;

void yysuccess(char *s);
void yyerror(const char *s);
void showLexicalError();
%}
%%

Bloc: %empty
    | Statement Bloc
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
    Declaration PureAffectation
    | CONST Declaration PureAffectation
    ;

Declaration:
    SimpleType ID
    | List ID
    ;

Tableau:
    ACCOLADEOUVRANTE Expression ComaLoopExpression ACCOLADEFERMANTE
    ;
    
ComaLoopExpression: %empty
    | COMA Expression ComaLoopExpression
    ;

PureAffectation:
    EQUALS Expression
    | EQUALS Tableau
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
    | Declaration SEMICOLUMN
    | Affectation SEMICOLUMN
    | Boucle
    | Condition
    | BREAK SEMICOLUMN
    | CONTINUE SEMICOLUMN
    ;

List:
    LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT
    ;

OperateurUnaire:
    INC
    | DEC
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

Variable:
    ID
    | ID CROCHETOUVRANT Expression CROCHETFERMANT
    ;

%%

void yysuccess(char *s){
    // fprintf(stdout, "%d: %s\n", yylineno, s);
    currentColumn+=yyleng;
}

void yyerror(const char *s) {
  fprintf(stdout, "File '%s', line %d, character %d :  %s \n", file, yylineno, currentColumn, s);
}

int main (void)
{
    // yydebug = 1;
    yyin=fopen(file, "r");
    if(yyin==NULL){
        printf("erreur dans l'ouverture du fichier");
        return 1;
    }
    yyparse();  

// printf("succ\n");

    return 0;
}

void showLexicalError() {

    char line[256], introError[80]; 

    fseek(yyin, 0, SEEK_SET);
    
    int i = 0; 

    while (fgets(line, sizeof(line), yyin)) { 
        i++; 
        if(i == yylineno) break;  
    } 
        
    sprintf(introError, "Lexical error in Line %d : Unrecognized character : ", yylineno);
    printf("%s%s", introError, line);  
    int j=1;
    while(j<currentColumn+strlen(introError)) { printf(" "); j++; }
    printf("^\n");


}