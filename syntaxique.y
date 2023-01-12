%define parse.error verbose

%{
#define simpleToArrayOffset 4
#define YYDEBUG 1
%}

%code requires{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "semantic.h"
#include "tableSymboles.h"
}

%union{
    char identifier[255];
    int type;
    int integerValue;
    double floatValue;
    bool booleanValue;
    bool isConstant;
    char stringValue[255];
    symbole * symbole;
    expression expression;
    tableau tableau;
}

// les terminaux only
%token IMPORT
%token FUN
%token CONST
%token <type> INTTYPE STRINGTYPE FLOATTYPE BOOLTYPE
%token LIST
%token TYPE
%token IF
%token ELSE
%token WHILE
%token FOR
%token IN
%token RETURN

%token <identifier> ID

%token <integerValue> INT
%token <stringValue> STRING
%token <booleanValue> BOOL
%token <floatValue > FLOAT

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

%type <expression> Expression;
%type <symbole> Declaration;
%type <type> SimpleType;
%type <tableau> Tableau;
%type <tableau> ComaLoopExpression;

%left COMA OR AND NEG

%nonassoc DOUBLEEQUALS EQUALS LESS GREATER LESSEQUALS GREATEREQUALS
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

char* file = "mytester.txt";

int currentColumn = 1;

symbole * tableSymboles = NULL;

void yysuccess(char *s);
void yyerror(const char *s);
void showLexicalError();
%}
%%

Bloc: %empty
    | Statement Bloc
    ;

SimpleType:
    INTTYPE { $$ = TYPE_INTEGER; }
    | FLOATTYPE { $$ = TYPE_FLOAT; }
    | STRINGTYPE { $$ = TYPE_STRING; }
    | BOOLTYPE { $$ = TYPE_BOOLEAN; }

Expression:
    INT { $$.type = TYPE_INTEGER; $$.integerValue = $1; }
    | FLOAT { $$.type = TYPE_FLOAT; $$.floatValue = $1; }
    | STRING { $$.type = TYPE_STRING; strcpy($$.stringValue, $1); }
    | BOOL { $$.type = TYPE_BOOLEAN; $$.booleanValue = $1; }
    | Variable
    | PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE
    | NEG Expression
    | SUB Expression
    | ADD Expression
    | Expression EQUALS Expression
    | Expression ADD Expression
    | Expression SUB Expression
    | Expression MUL Expression
    | Expression MOD Expression
    | Expression DIV Expression
    | Expression POW Expression
    | Expression ADDEQUALS Expression
    | Expression SUBEQUALS Expression
    | Expression MULEQUALS Expression
    | Expression DIVEQUALS Expression
    | Expression MODEQUALS Expression
    | Expression LESS Expression
    | Expression LESSEQUALS Expression
    | Expression GREATER Expression
    | Expression GREATEREQUALS Expression
    | Expression DOUBLEEQUALS Expression
    | Expression AND Expression
    | Expression OR Expression
    
DeclarationInitialisation:
    Declaration EQUALS Expression {
        if($1 != NULL){
            if($1->type == $3.type){
                char valeurString[255];
                valeurToString(&$3, valeurString);
                setValeur($1, valeurString);
            }else{
                printf("Type mismatch\n");
            }
        }
    }
    |Declaration EQUALS Tableau {
        if($1 != NULL && $3.type >= simpleToArrayOffset){
            if( $1->type == $3.type){
                printf("Type match\n");
                setTabValeur($1, $3.tabValeur, $3.length);
            }else{
                printf("Type mismatch\n");
            }
        }
    }
    ;

Declaration:
    SimpleType ID {
        if(rechercherSymbole(tableSymboles, $2) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($2, $1, false);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            printf("Identifiant deja declare : %s\n", $2);
            $$ = NULL;
        }
    }
    |CONST SimpleType ID {
        if(rechercherSymbole(tableSymboles, $3) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($3, $2, true);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            printf("Identifiant deja declare : %s\n", $3);
            $$ = NULL;
        }
    }
    |LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $6) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($6, $2 + simpleToArrayOffset, false);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            printf("Identifiant deja declare : %s\n", $6);
            $$ = NULL;
        }
    }
    |CONST LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $6) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($6, $2 + simpleToArrayOffset, true);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            printf("Identifiant deja declare : %s\n", $6);
            $$ = NULL;
        }
    }
    ;
    
Affectation:
    Variable EQUALS Expression { /*here we need to fetch the symbole first*/ }
    | Variable INC
    | Variable DEC
    | Variable ADDEQUALS Expression
    | Variable SUBEQUALS Expression
    | Variable MULEQUALS Expression
    | Variable DIVEQUALS Expression
    | Variable MODEQUALS Expression
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

For: 
    FOR PARENTHESEOUVRANTE DeclarationInitialisation SEMICOLUMN Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE
    ;

Boucle:
    While
    | For
    ;

Tableau: 
    ACCOLADEOUVRANTE Expression ACCOLADEFERMANTE {
        $$.type = $2.type + simpleToArrayOffset;
    
        char valeurString[255];
        valeurToString(&$2, valeurString);
        strcpy($$.tabValeur[0], valeurString);
        $$.length = 1;
    }
    | ACCOLADEOUVRANTE Expression ComaLoopExpression ACCOLADEFERMANTE {
        if($2.type == $3.type){
            
            // type of tableau is type of its content + simpleToArrayOffset
            $$.type = $2.type + simpleToArrayOffset;
            
            for(int i=0;i<$3.length;i++){
            strcpy($$.tabValeur[i], $3.tabValeur[i]);};

            printf("lololol\n\n\n");

            $$.length = $3.length;

            char valeurString[255];
            valeurToString(&$2, valeurString);

            strcpy($$.tabValeur[$$.length], valeurString);
            $$.length += 1;
        } else {
            $$.type = -1;
            printf("Le tableau doit contenir un seul type de donnees\n");
        }
    }
    ;

ComaLoopExpression:
    COMA Expression {
        $$.type = $2.type;
        char valeurString[255];
        valeurToString(&$2, valeurString);
        strcpy($$.tabValeur[0], valeurString);
        $$.length = 1;
    }
    |COMA Expression ComaLoopExpression {
        if($2.type == $3.type){
            $$.type= $2.type;

            for(int i=0;i<$3.length;i++){
            strcpy($$.tabValeur[i], $3.tabValeur[i]);};

            $$.length = $3.length;

            char valeurString[255];
            valeurToString(&$2, valeurString);

            strcpy($$.tabValeur[$$.length], valeurString);
            $$.length += 1;
        }else{
            $$.type = -1;
        }
    }
    ;

Variable:
    ID
    |ID CROCHETOUVRANT Expression CROCHETFERMANT
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
    yydebug = 1;
    yyin=fopen(file, "r");
    if(yyin==NULL){
        printf("erreur dans l'ouverture du fichier");
        return 1;
    }
    yyparse();  
    printf("now printing\n");
    afficherTableSymboles(tableSymboles);
    if(tableSymboles != NULL){
        free(tableSymboles);
    }

    fclose(yyin);

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