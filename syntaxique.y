%define parse.error verbose

%{
#define simpleToArrayOffset 4
#define YYDEBUG 1
#define RESET "\033[0m"
#define RED "\033[31m"     
#define MAGENTA "\033[35m"
#define GREEN "\033[32m" 
%}

%code requires{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "semantic.h"
#include "tableSymboles.h"
#include "quadruplets.h"
#include "pile.h"
#include "list.h"
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
    variable variable;
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
%type <variable> Variable;
%type <type> SimpleType;
%type <tableau> Tableau;
%type <tableau> ComaLoopExpression;

%left COMA OR AND NEG

%nonassoc DOUBLEEQUALS EQUALS LESS GREATER LESSEQUALS GREATEREQUALS
%nonassoc NOTEQUALS ADDEQUALS SUBEQUALS MULEQUALS DIVEQUALS MODEQUALS
%left ADD SUB
%left MUL DIV MOD

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

pile * stack;
quad * q;
int qc = 1;

bool isForLoop = false;
bool hasFailed = false;
qFifo * quadFifo;

void yysuccess(char *s);
void yyerror(const char *s);
void yyerrorSemantic(char *s);
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
    | Variable {
        if($1.symbole != NULL){
            char valeurString[255];
            char nameString[255];
            $$.isVariable = true;
            if($1.symbole->type < simpleToArrayOffset){
                getNom($1.symbole, nameString);
                strcpy($$.nameVariable, nameString);
                getValeur($1.symbole, valeurString);
                switch ($1.symbole->type){
                    case TYPE_INTEGER:
                        $$.integerValue = atoi(valeurString);
                        $$.type = TYPE_INTEGER;
                        break;
                    case TYPE_FLOAT:
                        $$.integerValue = atof(valeurString);
                        $$.type = TYPE_FLOAT;
                        break;
                    case TYPE_STRING:
                        strcpy($$.stringValue, valeurString);
                        $$.type = TYPE_STRING;
                        break;
                    case TYPE_BOOLEAN:
                        $$.booleanValue = strcmp(valeurString, "true") == 0;
                        $$.type = TYPE_BOOLEAN;
                        break;
                    default :
                        $$.type = -1;
                        break;
                    }
            }else{
                    getNom($1.symbole,nameString);
                    sprintf($$.nameVariable,"%s[%s]",nameString,$1.indexString);
                    getArrayElement($1.symbole, $1.index, valeurString);
                    switch ($1.symbole->type){
                        case TYPE_ARRAY_BOOLEAN:
                            $$.booleanValue = strcmp(valeurString, "true") == 0;;
                            $$.type = TYPE_BOOLEAN;
                            break;
                        case TYPE_ARRAY_FLOAT:
                            $$.floatValue = atof(valeurString);
                            $$.type = TYPE_FLOAT;
                            break;
                        case TYPE_ARRAY_INTEGER:
                            $$.integerValue = atoi(valeurString);
                            $$.type = TYPE_INTEGER;
                            break;
                        case TYPE_ARRAY_STRING:
                            strcpy($$.stringValue, valeurString);
                            $$.type = TYPE_STRING;
                            break;
                        default:
                            $$.type = -1;
                            break;
                }
            }
        }
    }
    | PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE {
            $$=$2;
    }
   | NEG Expression {
            if($2.type == TYPE_BOOLEAN)
            {
                $$.type=TYPE_BOOLEAN;
                $$.booleanValue=!$2.booleanValue;

                char buff[255];
                char qcString[20];
                strcpy(buff, ($2.booleanValue == true) ? "true" : "false");
                sprintf(qcString, "%s%d", "R",qc);
                strcpy($$.nameVariable,qcString);
                $$.isVariable=true;
                insererQuadreplet(&q, "NEG","", buff, qcString, qc);
                qc++;
            }
            else
            {
                yyerrorSemantic( "Non boolean expression found");
            }
    }
    | SUB Expression {
            if($2.type != TYPE_STRING)
            {
                
                if($2.type == TYPE_INTEGER)
                {
                    $$.type=TYPE_INTEGER;
                    $$.integerValue=0-$2.integerValue;
                
                    char buff[255];
                    char qcString[20];
                    sprintf(buff, "%d", $2.integerValue);
                    sprintf(qcString, "%s%d", "R",qc);
                    strcpy($$.nameVariable,qcString);
                    $$.isVariable=true;
                    insererQuadreplet(&q, "SUB","0", buff, qcString, qc);
                    qc++;
                }
                else
                {
                    if($2.type == TYPE_FLOAT)
                    {
                        $$.type=TYPE_FLOAT;
                        $$.floatValue=0.0-$2.floatValue;
                        
                        char buff[255];
                        char qcString[20];
                        sprintf(buff, "%f", $2.floatValue);
                        sprintf(qcString, "%s%d", "R",qc);
                        insererQuadreplet(&q, "SUB","0", buff, qcString, qc);
                        qc++;
                    }
                }
            }else{
                yyerrorSemantic( "Non numeric expression found");
            }
    }
    | ADD Expression {
            if($2.type != TYPE_STRING)
            {
                if($2.type == TYPE_INTEGER)
                {
                    $$.type=TYPE_INTEGER;
                    $$.integerValue=0+$2.integerValue;
                }
                else
                {
                    if($2.type == TYPE_FLOAT)
                    {
                        $$.type=TYPE_FLOAT;
                        $$.floatValue=0.0+$2.floatValue;
                    }
                }
            }
            else{
                yyerrorSemantic( "Non numeric expression found");
            }
    }
    | Expression ADD Expression {
            if($1.type == $3.type){
                    if($1.type == TYPE_STRING)
                    {
                        strcpy($$.stringValue,$1.stringValue);
                        strcat($$.stringValue,$3.stringValue);

                        char qcString[20];
                        sprintf(qcString, "%s%d", "R",qc);
                        strcpy($$.nameVariable,qcString);
                        $$.isVariable=true;
                        if($1.isVariable == true & $3.isVariable == true)
                        {
                            insererQuadreplet(&q, "ADD",$1.nameVariable, $3.nameVariable, qcString, qc);
                        }
                        else
                        {
                            if($1.isVariable == true)
                            {
                                insererQuadreplet(&q, "ADD",$1.nameVariable, $3.stringValue, qcString, qc);
                            }
                            else
                            {
                                if($3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "ADD",$1.stringValue, $3.nameVariable, qcString, qc);
                                }
                                else
                                {
                                    insererQuadreplet(&q, "ADD",$1.stringValue, $3.stringValue, qcString, qc);
                                }
                            }
                        }
                        qc++;
                    }
                    else{
                        if($1.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue+$3.integerValue;

                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true & $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "ADD",$1.nameVariable, $3.nameVariable, qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable == true)
                                {
                                    sprintf(buff2, "%d", $3.integerValue);
                                    insererQuadreplet(&q, "ADD",$1.nameVariable, buff2, qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable == true)
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        insererQuadreplet(&q, "ADD",buff, $3.nameVariable, qcString, qc);
                                    }
                                    else
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "ADD",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else {
                            if($1.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue+$3.floatValue;
                                
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true & $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "ADD",$1.nameVariable, $3.nameVariable, qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable == true)
                                    {
                                        sprintf(buff2, "%f", $3.floatValue);
                                        insererQuadreplet(&q, "ADD",$1.nameVariable, buff2, qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable == true)
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            insererQuadreplet(&q, "ADD",buff, $3.nameVariable, qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "ADD",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else
                            {
                                if($1.type == TYPE_BOOLEAN)
                                {
                                    $$.type=TYPE_BOOLEAN;
                                    if(($1.booleanValue) || ($3.booleanValue))
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else
                                    {
                                        $$.booleanValue=false;
                                    };

                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true & $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "ADD",$1.nameVariable, $3.nameVariable, qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                                            insererQuadreplet(&q, "ADD",$1.nameVariable, buff2, qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                                                insererQuadreplet(&q, "ADD",buff, $3.nameVariable, qcString, qc);
                                            }
                                            else
                                            {
                                                strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                                                strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                                                insererQuadreplet(&q, "ADD",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }
                    }
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression SUB Expression {
            if($1.type == $3.type){
                    if($1.type == TYPE_STRING)
                    {
                        yyerrorSemantic( "Type mismatch");
                    }
                    else{
                        if($1.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue-$3.integerValue;

                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true & $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "SUB",$1.nameVariable, $3.nameVariable, qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable == true)
                                {
                                    sprintf(buff2, "%d", $3.integerValue);
                                    insererQuadreplet(&q, "SUB",$1.nameVariable, buff2, qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable == true)
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        insererQuadreplet(&q, "SUB",buff, $3.nameVariable, qcString, qc);
                                    }
                                    else
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "SUB",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else {
                            if($1.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue-$3.floatValue;

                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true & $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "SUB",$1.nameVariable, $3.nameVariable, qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable == true)
                                    {
                                        sprintf(buff2, "%f", $3.floatValue);
                                        insererQuadreplet(&q, "SUB",$1.nameVariable, buff2, qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable == true)
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            insererQuadreplet(&q, "SUB",buff, $3.nameVariable, qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "SUB",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                        }
                    }
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression MUL Expression {
            if($1.type == $3.type){
                    if($1.type == TYPE_STRING)
                    {
                        yyerrorSemantic( "Type mismatch");
                    }
                    else{
                        if($1.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue * $3.integerValue;

                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true & $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable, qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable == true)
                                {
                                    sprintf(buff2, "%d", $3.integerValue);
                                    insererQuadreplet(&q, "MUL",$1.nameVariable, buff2, qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable == true)
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        insererQuadreplet(&q, "MUL",buff, $3.nameVariable, qcString, qc);
                                    }
                                    else
                                    {
                                        sprintf(buff, "%d", $1.integerValue);
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else {
                            if($1.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue * $3.floatValue;

                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true & $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable, qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable == true)
                                    {
                                        sprintf(buff2, "%f", $3.floatValue);
                                        insererQuadreplet(&q, "MUL",$1.nameVariable, buff2, qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable == true)
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            insererQuadreplet(&q, "MUL",buff, $3.nameVariable, qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%f", $1.floatValue);
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else
                            {
                                if($1.type == TYPE_BOOLEAN)
                                {
                                    $$.type=TYPE_BOOLEAN;
                                    if(($1.booleanValue) && ($3.booleanValue))
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else
                                    {
                                        $$.booleanValue=false;
                                    };

                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true & $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable, qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                                            insererQuadreplet(&q, "MUL",$1.nameVariable, buff2, qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                                                insererQuadreplet(&q, "MUL",buff, $3.nameVariable, qcString, qc);
                                            }
                                            else
                                            {
                                                strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                                                strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                                                insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }
                    }
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression MOD Expression {
            if($1.type == $3.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        yyerrorSemantic( "Division by zero");
                    }
                    else
                    {
                        if($$.type == TYPE_STRING)
                        {
                            yyerrorSemantic( "Type mismatch");
                        }
                        else{
                            if($$.type == TYPE_INTEGER)
                            {
                                $$.integerValue=$1.integerValue % $3.integerValue;

                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "DIV",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                        sprintf(qcString, "%s%d", "R",qc);
                                        insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                        sprintf(qcString, "%s%d", "R",qc);
                                        insererQuadreplet(&q, "SUB",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "DIV",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                            sprintf(buff2, "%d", $3.integerValue);
                                            sprintf(qcString, "%s%d", "R",qc);
                                            insererQuadreplet(&q, "MUL",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                            strcpy(buff2, qcString);
                                            sprintf(qcString, "%s%d", "R",qc);
                                            insererQuadreplet(&q, "SUB",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                insererQuadreplet(&q, "DIV",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                                strcpy(buff, qcString);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "MUL",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                                sprintf(buff, "%d", $1.integerValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "SUB",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                            }
                                            else
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                sprintf(buff2, "%d", $3.integerValue);
                                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                                qc++;
                                                strcpy(buff, qcString);
                                                sprintf(buff2, "%d", $3.integerValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                                qc++;
                                                sprintf(buff, "%d", $1.integerValue);
                                                strcpy(buff2, qcString);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "SUB",buff, buff2,qcString, qc);
                                                qc++;
                                            }
                                        }
                                    }
                            }
                            else {
                                if($$.type == TYPE_FLOAT)
                                {
                                    $$.floatValue=fmod($1.floatValue,$3.floatValue);

                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "DIV",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                        sprintf(qcString, "%s%d", "R",qc);
                                        insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                        sprintf(qcString, "%s%d", "R",qc);
                                        insererQuadreplet(&q, "SUB",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "DIV",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                            sprintf(buff2, "%f", $3.floatValue);
                                            sprintf(qcString, "%s%d", "R",qc);
                                            insererQuadreplet(&q, "MUL",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                            strcpy(buff2, qcString);
                                            sprintf(qcString, "%s%d", "R",qc);
                                            insererQuadreplet(&q, "SUB",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "DIV",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                                strcpy(buff, qcString);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "MUL",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "SUB",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                                qc++;
                                                strcpy(buff, qcString);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                                qc++;
                                                sprintf(buff, "%f", $1.floatValue);
                                                strcpy(buff2, qcString);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "SUB",buff, buff2,qcString, qc);
                                                qc++;
                                            }
                                        }
                                    }   
                                }
                            }
                        }
                    }
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression DIV Expression {
            if($1.type == $3.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        yyerrorSemantic( "Division by zero");
                    }
                    else
                    {
                        if($1.type == TYPE_STRING)
                        {
                            yyerrorSemantic( "Type mismatch");
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                $$.integerValue=$1.integerValue / $3.integerValue;

                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "DIV",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "DIV",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                insererQuadreplet(&q, "DIV",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                            }
                                            else
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                sprintf(buff2, "%d", $3.integerValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                                qc++;   
                                            }
                                        }
                                    }
                                
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    $$.floatValue=$1.floatValue / $3.floatValue;
                                char buff2[255];
                                char buff[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "DIV",$1.nameVariable, $3.nameVariable,qcString, qc);
                                        qc++;
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "DIV",$1.nameVariable, buff2,qcString, qc);
                                            qc++;
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "DIV",buff, $3.nameVariable,qcString, qc);
                                                qc++;
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                sprintf(qcString, "%s%d", "R",qc);
                                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                                qc++;   
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression POW Expression {
            if(($1.type == $3.type)){
                if($1.type == TYPE_STRING)
                    {
                        yyerrorSemantic( "Type mismatch");
                    }
                    else{
                        if($1.type == TYPE_INTEGER)
                        {
                            $$.integerValue=pow($1.integerValue,$3.integerValue);
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            int cpt = 0;
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        while(cpt<$3.integerValue)
                                        {
                                            insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable,qcString, qc);
                                            strcpy(buff, qcString);
                                            qc++;
                                            sprintf(qcString, "%s%d", "R",qc);
                                            cpt++;
                                        }
                                    }
                                    else
                                    {
                                        if($1.isVariable == true)
                                        {
                                            sprintf(buff2, "%d", $3.integerValue);
                                            while(cpt<$3.integerValue)
                                            {
                                                insererQuadreplet(&q, "MUL",$1.nameVariable, buff2,qcString, qc);
                                                strcpy(buff, qcString);
                                                qc++;
                                                sprintf(qcString, "%s%d", "R",qc);
                                                cpt++;
                                            }
                                        }
                                        else
                                        {
                                            if($3.isVariable == true)
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                while(cpt<$3.integerValue)
                                                {
                                                    insererQuadreplet(&q, "MUL",buff, $3.nameVariable,qcString, qc);
                                                    strcpy(buff, qcString);
                                                    qc++;
                                                    sprintf(qcString, "%s%d", "R",qc);
                                                    cpt++;
                                                }
                                            }
                                            else
                                            {
                                                sprintf(buff, "%d", $1.integerValue);
                                                sprintf(buff2, "%d", $3.integerValue);
                                                while(cpt<$3.integerValue)
                                                {
                                                    insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                                    strcpy(buff, qcString);
                                                    qc++;
                                                    sprintf(qcString, "%s%d", "R",qc);
                                                    cpt++;
                                                }
                                            }
                                        }
                                    }
                                    
                            
                        }
                        else {
                            if($1.type == TYPE_FLOAT && $3.type == TYPE_INTEGER)
                            {
                                $$.floatValue=pow($1.floatValue,$3.integerValue);

                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                int cpt = 0;
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                        {
                                            while(cpt<$3.integerValue)
                                            {
                                                
                                                insererQuadreplet(&q, "MUL",$1.nameVariable, $3.nameVariable, qcString,qc);
                                                strcpy(buff, qcString);
                                                qc++;
                                                sprintf(qcString, "%s%d", "R",qc);
                                                cpt++;
                                            }
                                        }
                                        else
                                        {
                                            if($1.isVariable == true)
                                            {
                                                sprintf(buff2, "%d", $3.integerValue);
                                                while(cpt<$3.integerValue)
                                                {
                                                    insererQuadreplet(&q, "MUL",$1.nameVariable, buff2,qcString, qc);
                                                    strcpy(buff, qcString);
                                                    qc++;
                                                    sprintf(qcString, "%s%d", "R",qc);
                                                    cpt++;
                                                }
                                            }
                                            else
                                            {
                                                if($3.isVariable == true)
                                                {
                                                    sprintf(buff, "%f", $1.floatValue);
                                                    while(cpt<$3.integerValue)
                                                    {
                                                        insererQuadreplet(&q, "MUL",buff, $3.nameVariable,qcString, qc);
                                                        strcpy(buff, qcString);
                                                        qc++;
                                                        sprintf(qcString, "%s%d", "R",qc);
                                                        cpt++;
                                                    }
                                                }
                                                else
                                                {
                                                    sprintf(buff, "%f", $1.floatValue);
                                                    sprintf(buff2, "%d", $3.integerValue);
                                                    while(cpt<$3.integerValue)
                                                    {
                                                        insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                                        strcpy(buff, qcString);
                                                        qc++;
                                                        sprintf(qcString, "%s%d", "R",qc);
                                                        cpt++;
                                                    }
                                                }
                                            }
                                        }
                                    
                                }
                            }
                    }
            }
            else{
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression LESS Expression {
            if($1.type == $3.type){
                    $$.type=TYPE_BOOLEAN;
                        if($1.type == TYPE_STRING)
                        {
                            if(strcmp($1.stringValue,$3.stringValue)< 0)
                            {
                                $$.booleanValue=true;
                            }
                            else{
                                $$.booleanValue=false;
                            }
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "LT",$1.nameVariable, $3.nameVariable,qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable==true)
                                {
                                    strcpy(buff2, $3.stringValue);
                                    insererQuadreplet(&q, "LT",$1.nameVariable, buff2,qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable==true)
                                    {
                                        strcpy(buff, $1.stringValue);
                                        insererQuadreplet(&q, "LT",buff, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        strcpy(buff, $1.stringValue);
                                        strcpy(buff2, $3.stringValue);
                                        insererQuadreplet(&q, "LT",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue < $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                }
                                else{
                                    $$.booleanValue=false;
                                }
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "LT",$1.nameVariable, $3.nameVariable,qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable==true)
                                    {
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "LT",$1.nameVariable, buff2,qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable==true)
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            insererQuadreplet(&q, "LT",buff, $3.nameVariable,qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "LT",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    if($1.floatValue < $3.floatValue)
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else{
                                        $$.booleanValue=false;
                                    }
                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "LT",$1.nameVariable, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable==true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "LT",$1.nameVariable, buff2,qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable==true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "LT",buff, $3.nameVariable,qcString, qc);
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "LT",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }   
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression LESSEQUALS Expression {
            if($1.type == $3.type){
                        $$.type=TYPE_BOOLEAN;
                        if($1.type == TYPE_STRING)
                        {
                            if(strcmp($1.stringValue,$3.stringValue)<= 0)
                            {
                                $$.booleanValue=true;
                            }
                            else{
                                $$.booleanValue=false;
                            }
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "LTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable==true)
                                {
                                    strcpy(buff2, $3.stringValue);
                                    insererQuadreplet(&q, "LTE",$1.nameVariable, buff2,qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable==true)
                                    {
                                        strcpy(buff, $1.stringValue);
                                        insererQuadreplet(&q, "LTE",buff, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        strcpy(buff, $1.stringValue);
                                        strcpy(buff2, $3.stringValue);
                                        insererQuadreplet(&q, "LTE",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue <= $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                }
                                else{
                                    $$.booleanValue=false;
                                }
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "LTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable==true)
                                    {
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "LTE",$1.nameVariable, buff2,qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable==true)
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            insererQuadreplet(&q, "LTE",buff, $3.nameVariable,qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "LTE",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    if($1.floatValue <= $3.floatValue)
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else{
                                        $$.booleanValue=false;
                                    }
                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "LTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable==true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "LTE",$1.nameVariable, buff2,qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable==true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "LTE",buff, $3.nameVariable,qcString, qc);
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "LTE",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }   
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression GREATER Expression {
            if($1.type == $3.type){
                $$.type=TYPE_BOOLEAN;
                        if($1.type == TYPE_STRING)
                        {
                            if(strcmp($1.stringValue,$3.stringValue)> 0)
                            {
                                $$.booleanValue=true;
                            }
                            else{
                                $$.booleanValue=false;
                            }
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "GT",$1.nameVariable, $3.nameVariable,qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable==true)
                                {
                                    strcpy(buff2, $3.stringValue);
                                    insererQuadreplet(&q, "GT",$1.nameVariable, buff2,qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable==true)
                                    {
                                        strcpy(buff, $1.stringValue);
                                        insererQuadreplet(&q, "GT",buff, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        strcpy(buff, $1.stringValue);
                                        strcpy(buff2, $3.stringValue);
                                        insererQuadreplet(&q, "GT",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;

                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue > $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                }
                                else{
                                    $$.booleanValue=false;
                                }
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "GT",$1.nameVariable, $3.nameVariable,qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable==true)
                                    {
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "GT",$1.nameVariable, buff2,qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable==true)
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            insererQuadreplet(&q, "GT",buff, $3.nameVariable,qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "GT",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    if($1.floatValue > $3.floatValue)
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else{
                                        $$.booleanValue=false;
                                    }
                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "GT",$1.nameVariable, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable==true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "GT",$1.nameVariable, buff2,qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable==true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "GT",buff, $3.nameVariable,qcString, qc);
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "GT",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }   
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression GREATEREQUALS Expression {
            if($1.type == $3.type){
                $$.type=TYPE_BOOLEAN;
                        if($1.type == TYPE_STRING)
                        {
                            if(strcmp($1.stringValue,$3.stringValue)>= 0)
                            {
                                $$.booleanValue=true;
                            }
                            else{
                                $$.booleanValue=false;
                            }
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "GTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable==true)
                                {
                                    strcpy(buff2, $3.stringValue);
                                    insererQuadreplet(&q, "GTE",$1.nameVariable, buff2,qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable==true)
                                    {
                                        strcpy(buff, $1.stringValue);
                                        insererQuadreplet(&q, "GTE",buff, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        strcpy(buff, $1.stringValue);
                                        strcpy(buff2, $3.stringValue);
                                        insererQuadreplet(&q, "GTE",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue >= $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                }
                                else{
                                    $$.booleanValue=false;
                                }
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "GTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable==true)
                                    {
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "GTE",$1.nameVariable, buff2,qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable==true)
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            insererQuadreplet(&q, "GTE",buff, $3.nameVariable,qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "GTE",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    if($1.floatValue >= $3.floatValue)
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else{
                                        $$.booleanValue=false;
                                    }
                                    char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "GTE",$1.nameVariable, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable==true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "GTE",$1.nameVariable, buff2,qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable==true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "GTE",buff, $3.nameVariable,qcString, qc);
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "GTE",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                                }
                            }
                        }   
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression DOUBLEEQUALS Expression {
            if($1.type == $3.type){
                $$.type=TYPE_BOOLEAN;
                        if($1.type == TYPE_STRING)
                        {
                            if(strcmp($1.stringValue,$3.stringValue) == 0)
                            {
                                $$.booleanValue=true;
                            }
                            else{
                                $$.booleanValue=false;
                            }
                            char buff[255];
                            char buff2[255];
                            char qcString[20];
                            sprintf(qcString, "%s%d", "R",qc);
                            strcpy($$.nameVariable,qcString);
                            $$.isVariable=true;
                            if($1.isVariable == true && $3.isVariable == true)
                            {
                                insererQuadreplet(&q, "ET",$1.nameVariable, $3.nameVariable,qcString, qc);
                            }
                            else
                            {
                                if($1.isVariable==true)
                                {
                                    strcpy(buff2, $3.stringValue);
                                    insererQuadreplet(&q, "ET",$1.nameVariable, buff2,qcString, qc);
                                }
                                else
                                {
                                    if($3.isVariable==true)
                                    {
                                        strcpy(buff, $1.stringValue);
                                        insererQuadreplet(&q, "ET",buff, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        strcpy(buff, $1.stringValue);
                                        strcpy(buff2, $3.stringValue);
                                        insererQuadreplet(&q, "ET",buff, buff2,qcString, qc);
                                    }
                                }
                            }
                            qc++;
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue == $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                }
                                else{
                                    $$.booleanValue=false;
                                }
                                char buff[255];
                                char buff2[255];
                                char qcString[20];
                                sprintf(qcString, "%s%d", "R",qc);
                                strcpy($$.nameVariable,qcString);
                                $$.isVariable=true;
                                if($1.isVariable == true && $3.isVariable == true)
                                {
                                    insererQuadreplet(&q, "ET",$1.nameVariable, $3.nameVariable,qcString, qc);
                                }
                                else
                                {
                                    if($1.isVariable==true)
                                    {
                                        sprintf(buff2, "%d", $3.integerValue);
                                        insererQuadreplet(&q, "ET",$1.nameVariable, buff2,qcString, qc);
                                    }
                                    else
                                    {
                                        if($3.isVariable==true)
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            insererQuadreplet(&q, "ET",buff, $3.nameVariable,qcString, qc);
                                        }
                                        else
                                        {
                                            sprintf(buff, "%d", $1.integerValue);
                                            sprintf(buff2, "%d", $3.integerValue);
                                            insererQuadreplet(&q, "ET",buff, buff2,qcString, qc);
                                        }
                                    }
                                }
                                qc++;
                            }
                            else {
                                if($1.type == TYPE_FLOAT)
                                {
                                    if($1.floatValue == $3.floatValue)
                                    {
                                        $$.booleanValue=true;
                                    }
                                    else{
                                        $$.booleanValue=false;
                                    }
                                }
                                char buff[255];
                                    char buff2[255];
                                    char qcString[20];
                                    sprintf(qcString, "%s%d", "R",qc);
                                    strcpy($$.nameVariable,qcString);
                                    $$.isVariable=true;
                                    if($1.isVariable == true && $3.isVariable == true)
                                    {
                                        insererQuadreplet(&q, "ET",$1.nameVariable, $3.nameVariable,qcString, qc);
                                    }
                                    else
                                    {
                                        if($1.isVariable==true)
                                        {
                                            sprintf(buff2, "%f", $3.floatValue);
                                            insererQuadreplet(&q, "ET",$1.nameVariable, buff2,qcString, qc);
                                        }
                                        else
                                        {
                                            if($3.isVariable==true)
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                insererQuadreplet(&q, "ET",buff, $3.nameVariable,qcString, qc);
                                            }
                                            else
                                            {
                                                sprintf(buff, "%f", $1.floatValue);
                                                sprintf(buff2, "%f", $3.floatValue);
                                                insererQuadreplet(&q, "ET",buff, buff2,qcString, qc);
                                            }
                                        }
                                    }
                                    qc++;
                            }
                        }   
            }
            else
            {
                yyerrorSemantic( "Type mismatch");
            }
    }
    | Expression AND Expression {
        if($1.type == TYPE_BOOLEAN && $3.type == TYPE_BOOLEAN)
        {
            if($1.booleanValue && $3.booleanValue)
            {
                $$.booleanValue=true;
            }
            else{
                $$.booleanValue=false;
            }
            char buff[255];
            char buff2[255];
            char qcString[20];
            sprintf(qcString, "%s%d", "R",qc);
            strcpy($$.nameVariable,qcString);
            $$.isVariable=true;
            if($1.isVariable == true & $3.isVariable == true)
            {
                insererQuadreplet(&q, "AND",$1.nameVariable, $3.nameVariable, qcString, qc);
            }
            else
            {
                if($1.isVariable == true)
                {
                    strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                    insererQuadreplet(&q, "AND",$1.nameVariable, buff2, qcString, qc);
                }
                else
                {
                    if($3.isVariable == true)
                    {
                        strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                        insererQuadreplet(&q, "AND",buff, $3.nameVariable, qcString, qc);
                    }
                    else
                    {
                        strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                        strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                        insererQuadreplet(&q, "AND",buff, buff2,qcString, qc);
                    }
                }
            }
            qc++;
        }
        else
        {
            yyerrorSemantic( "Type missmatch");
        }
    }
    | Expression OR Expression {
        if($1.type == TYPE_BOOLEAN && $3.type == TYPE_BOOLEAN)
        {
            if($1.booleanValue || $3.booleanValue)
            {
                $$.booleanValue=true;
            }
            else{
                $$.booleanValue=false;
            }
            char buff[255];
            char buff2[255];
            char qcString[20];
            sprintf(qcString, "%s%d", "R",qc);
            strcpy($$.nameVariable,qcString);
            $$.isVariable=true;
            if($1.isVariable == true & $3.isVariable == true)
            {
                insererQuadreplet(&q, "OR",$1.nameVariable, $3.nameVariable, qcString, qc);
            }
            else
            {
                if($1.isVariable == true)
                {
                    strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                    insererQuadreplet(&q, "OR",$1.nameVariable, buff2, qcString, qc);
                }
                else
                {
                    if($3.isVariable == true)
                    {
                        strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                        insererQuadreplet(&q, "OR",buff, $3.nameVariable, qcString, qc);
                    }
                    else
                    {
                        strcpy(buff, ($1.booleanValue == true) ? "true" : "false");
                        strcpy(buff, ($3.booleanValue == true) ? "true" : "false");
                        insererQuadreplet(&q, "OR",buff, buff2,qcString, qc);
                    }
                }
            }
            qc++;
        }
        else
        {
            yyerrorSemantic( "Type missmatch");         
        }

    }

    
DeclarationInitialisation:
    Declaration EQUALS Expression {
        if($1 != NULL){
            if($1->type == $3.type){
                char valeurString[255];
                valeurToString($3, valeurString);
                setValeur($1, valeurString);
                if($3.isVariable)
                {
                    insererQuadreplet(&q, ":=", $3.nameVariable, "", $1->nom, qc);                    
                }
                else
                {
                    insererQuadreplet(&q, ":=", valeurString, "", $1->nom, qc);
                }
                qc++;
            }else{
                yyerrorSemantic( "Type mismatch");
            }
        }
    }
    |Declaration EQUALS Tableau {
        if($1 != NULL && $3.type >= simpleToArrayOffset){
            if( $1->type == $3.type){
                setTabValeur($1, $3.tabValeur, $3.length);

                for(int i = 0; i< $3.length; i++){
                    char buff[255];
                    sprintf(buff, "%s[%d]", $1->nom, i);
                    insererQuadreplet(&q, ":=", $3.tabValeur[i], "", buff, qc);
                    qc++;
                };
            }else{
                yyerrorSemantic( "Type mismatch");
            }
        }
    }
    ;

Declaration:
// NO QUADS
    SimpleType ID {
        if(rechercherSymbole(tableSymboles, $2) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($2, $1, false, 0);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            yyerrorSemantic( "Id already declared");
            $$ = NULL;
        }
    }
    // NO QUADS
    |CONST SimpleType ID {
        if(rechercherSymbole(tableSymboles, $3) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            symbole * nouveauSymbole = creerSymbole($3, $2, true, 0);
            insererSymbole(&tableSymboles, nouveauSymbole);
            $$ = nouveauSymbole;
        }else{
            yyerrorSemantic( "Id already declared ");
            $$ = NULL;
        }
    }
    |LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $6) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            if($4.type != TYPE_INTEGER || $4.integerValue < 1){
                yyerrorSemantic( "Array dimension must be a positive integer");
            }else{
                symbole * nouveauSymbole = creerSymbole($6, $2 + simpleToArrayOffset, false, $4.integerValue);
                insererSymbole(&tableSymboles, nouveauSymbole);
                $$ = nouveauSymbole;

                char buff[255];
                sprintf(buff, "%d", $4.integerValue -1);
                insererQuadreplet(&q, "BOUNDS","0", buff, "", qc);
                qc++;

                sprintf(buff, "%d", $4.integerValue -1);
                insererQuadreplet(&q, "ADEC", $6, "", "", qc);
                qc++;
            };
        }else{
            yyerrorSemantic( "Id already declared");
            $$ = NULL;
        }
    }
    |CONST LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $7) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            if($5.type != TYPE_INTEGER || $5.integerValue < 1){
                yyerrorSemantic( "Array dimension must be a positive integer");
            }else{
                symbole * nouveauSymbole = creerSymbole($7, $3 + simpleToArrayOffset, true, $5.integerValue);
                insererSymbole(&tableSymboles, nouveauSymbole);
                $$ = nouveauSymbole;

                char buff[255];
                sprintf(buff, "%d", $5.integerValue);
                insererQuadreplet(&q, "BOUNDS","0", buff, "", qc);
                qc++;

                sprintf(buff, "%d", $5.integerValue);
                insererQuadreplet(&q, "ADEC", $7, "", "", qc);
                qc++;
            };
        }else{
            yyerrorSemantic( "Id already declared");
            $$ = NULL;
        }
    }
    ;
    
Affectation:
    Variable EQUALS Expression { 
        if($1.symbole != NULL){
            if($1.symbole->isConstant && $1.symbole->hasBeenInitialized){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
            if($1.symbole->type % simpleToArrayOffset != $3.type ){
                yyerrorSemantic( "Type mismatch");
            }else{
                char valeurString[255];

                if($1.symbole->type < simpleToArrayOffset)

                    {
                        setValeur($1.symbole, valeurString);

                        if($3.isVariable){
                            strcpy(valeurString , $3.nameVariable);
                        }else{
                            valeurToString($3,valeurString);
                        }

                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet(":=", valeurString, "", $1.symbole->nom, qc));
                        }else{
                            insererQuadreplet(&q, ":=", valeurString, "", $1.symbole->nom, qc);
                            qc++;
                        }

                    }
                else
                    {
                        setArrayElement($1.symbole, $1.index, valeurString);

                        char buff[255];
                        sprintf(buff, "%s[%s]", $1.symbole->nom, $1.indexString);

                        if($3.isVariable){
                            strcpy(valeurString , $3.nameVariable);
                        }else{
                            valeurToString($3,valeurString);
                        }

                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet(":=", valeurString, "", buff, qc));
                        }else{
                            insererQuadreplet(&q, ":=", valeurString, "", buff, qc);
                            qc++;
                        }
                    }

            }
        }
        }

    }        
    | Variable INC {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                    yyerrorSemantic("Cannot reassign a value to a constant");
                }else{
                if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                    yyerrorSemantic( "Non numeric variable found");
                }else{

                    char valeurString[255];

                    if($1.symbole->type < simpleToArrayOffset)

                        {
                            getValeur($1.symbole, valeurString);
                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("ADD", $1.symbole->nom, "1", $1.symbole->nom, qc));
                            }else{

                                insererQuadreplet(&q, "ADD", $1.symbole->nom, "1", $1.symbole->nom, qc);
                                qc++;
                            }
                        
                        }
                    else
                        {
                            getArrayElement($1.symbole, $1.index, valeurString);

                            char buff[255];
                            sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("ADD", buff, "1", buff, qc));
                        }else{

                            insererQuadreplet(&q, "ADD", buff, "1", buff, qc);
                            qc++;
                        }
                        }


                    if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeur = atoi(valeurString);
                        valeur++;
                        sprintf(valeurString, "%d", valeur);
                    }else{
                        double valeur = atof(valeurString);
                        valeur++;
                        sprintf(valeurString,"%.4f",valeur);
                    };
                    if($1.symbole->type < simpleToArrayOffset)

                        {
                            setValeur($1.symbole, valeurString);
                        }
                    else
                        {
                            setArrayElement($1.symbole, $1.index, valeurString);
                        }

                }
            }
        }
        }
            
    }
    | Variable DEC {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                    yyerrorSemantic( "Non numeric variable found");
                }else{
                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset){
                        getValeur($1.symbole, valeurString);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("SUB", $1.symbole->nom, "1", $1.symbole->nom, qc));
                        }else{

                        insererQuadreplet(&q, "SUB", $1.symbole->nom, "1", $1.symbole->nom, qc);
                        qc++;
                        }
                        
                    }else{
                        getArrayElement($1.symbole, $1.index, valeurString);

                        char buff[255];
                        sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("SUB", buff, "1", buff, qc));
                        }else{

                        insererQuadreplet(&q, "SUB", buff, "1", buff, qc);
                        qc++;
                        }
                    }


                    if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeur = atoi(valeurString);
                        valeur--;
                        sprintf(valeurString, "%d", valeur);
                    }else{
                        double valeur = atof(valeurString);
                        valeur--;
                        sprintf(valeurString,"%.4f",valeur);
                    }

                    if($1.symbole->type < simpleToArrayOffset){
                        setValeur($1.symbole, valeurString);
                    }
                    else{
                        setArrayElement($1.symbole, $1.index, valeurString);
                    }

                }
            }
            }
        }
    }     
    | Variable ADDEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    yyerrorSemantic( "Type mismatch");
                }else{
                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)

                        {
                            getValeur($1.symbole, valeurString);

                            
                        }
                    else
                        {
                            getArrayElement($1.symbole, $1.index, valeurString);
                            
                        }

                    if($1.symbole->type % simpleToArrayOffset == TYPE_STRING){
                        {
                            strcat(valeurString,$3.stringValue);
                        }

                    }else if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeurExpression = $3.integerValue;
                        int valeur = atoi(valeurString);
                        int result = valeur + valeurExpression;
                        sprintf(valeurString, "%d", result);

                    }else if($1.symbole->type % simpleToArrayOffset == TYPE_FLOAT){
                        double valeurExpression = $3.floatValue;
                        double valeur = atof(valeurString);
                        double result = valeur + valeurExpression;
                        sprintf(valeurString,"%.4f",result); 
                    }else{
                        if($3.booleanValue){
                            strcpy(valeurString, "true");
                        };
                    };

                    char expressionValue[255];

                    if($3.isVariable){
                        strcpy(expressionValue , $3.nameVariable);
                    }else{
                        valeurToString($3, expressionValue);
                    }

                    if($1.symbole->type < simpleToArrayOffset)
                        {
                            setValeur($1.symbole, valeurString);

                            
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("ADD", $1.symbole->nom, expressionValue, $1.symbole->nom, qc));
                        }else{

                            insererQuadreplet(&q, "ADD", $1.symbole->nom, expressionValue, $1.symbole->nom, qc);
                            qc++;
                        }
                        }
                    else
                        {
                            setArrayElement($1.symbole, $1.index, valeurString);

                            char buff[255];
                            sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("ADD", buff, expressionValue, buff, qc));
                        }else{

                            insererQuadreplet(&q, "ADD", buff, expressionValue, buff, qc);
                            qc++;
                        }
                        }
                }

                }
            }
        }
    }   
    | Variable SUBEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    yyerrorSemantic( "Type mismatch");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                        yyerrorSemantic( "Non numeric variable found");
                    }else{

                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)

                        {
                            getValeur($1.symbole, valeurString);

                        }
                    else
                        {
                            getArrayElement($1.symbole, $1.index, valeurString);


                        }


                    if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeurExpression = $3.integerValue;
                        int valeur = atoi(valeurString);
                        int result = valeur - valeurExpression;
                        sprintf(valeurString, "%d", result);

                    }else{
                        double valeurExpression = $3.floatValue;
                        double valeur = atof(valeurString);
                        double result = valeur - valeurExpression;
                        sprintf(valeurString,"%.4f",result);

                    };

                    char expressionValue[255];
                    if($3.isVariable){
                        strcpy(expressionValue , $3.nameVariable);
                    }else{
                        valeurToString($3, expressionValue);
                    }
                    if($1.symbole->type < simpleToArrayOffset)
                        {
                            setValeur($1.symbole, valeurString);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("SUB", $1.symbole->nom, expressionValue, $1.symbole->nom, qc));
                        }else{

                            insererQuadreplet(&q, "SUB", $1.symbole->nom, expressionValue, $1.symbole->nom, qc);
                            qc++;
                        }
                        }
                    else
                        {
                            setArrayElement($1.symbole, $1.index, valeurString);

                            char buff[255];
                            sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("SUB", buff, expressionValue, buff, qc));
                        }else{

                            insererQuadreplet(&q, "SUB", buff, expressionValue, buff, qc);
                            qc++;
                        }
                        }
                    }
                }
                }
            }
        }
    }
    | Variable MULEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    yyerrorSemantic( "Type mismatch");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER
                    && $1.symbole->type % simpleToArrayOffset != TYPE_BOOLEAN){
                        yyerrorSemantic( "Non numeric non boolean variable found");
                    }else{

                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)

                        {
                            getValeur($1.symbole, valeurString);
                        }
                    else{
                        getArrayElement($1.symbole, $1.index, valeurString);
                    }


                    if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeurExpression = $3.integerValue;
                        int valeur = atoi(valeurString);
                        int result = valeur * valeurExpression;
                        sprintf(valeurString, "%d", result);

                    }else if($1.symbole->type % simpleToArrayOffset == TYPE_FLOAT){
                        double valeurExpression = $3.floatValue;
                        double valeur = atof(valeurString);
                        double result = valeur * valeurExpression;
                        sprintf(valeurString,"%.4f",result);


                    }else{
                        if($3.booleanValue){
                            if($1.symbole->type < simpleToArrayOffset){
                                if(!strcmp($1.symbole->valeur, "true")){
                                    strcpy(valeurString, "false");
                                };
                            }else{
                                if(!strcmp($1.symbole->array->tabValeur[$1.index], "true")){
                                    strcpy(valeurString, "false");
                                };
                            };

                        };
                        
                    };
                    char expressionValue[255];
                    if($3.isVariable){
                        strcpy(expressionValue , $3.nameVariable);
                    }else{
                        valeurToString($3, expressionValue);
                    }
                    if($1.symbole->type < simpleToArrayOffset)
                        {
                            setValeur($1.symbole, valeurString);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("MUL", $1.symbole->nom, expressionValue, $1.symbole->nom, qc));
                        }else{

                            insererQuadreplet(&q, "MUL", $1.symbole->nom, expressionValue, $1.symbole->nom, qc);
                            qc++;
                        }
                        }
                    else
                        {
                            setArrayElement($1.symbole, $1.index, valeurString);

                            char buff[255];
                            sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                        if(isForLoop){
                            pushFifo(quadFifo, creerQuadreplet("MUL", buff, expressionValue, buff, qc));
                        }else{

                            insererQuadreplet(&q, "MUL", buff, expressionValue, buff, qc);
                            qc++;
                        }
                        }
                    }
                }
            }
            }
        }
    }
    | Variable DIVEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    yyerrorSemantic( "Type mismatch");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                        yyerrorSemantic( "Non numeric variable found");
                    }else{
                        
                        char valeurString[255];

                        if($1.symbole->type < simpleToArrayOffset)

                            
                            {
                                getValeur($1.symbole, valeurString);

                            }
                        else{
                            getArrayElement($1.symbole, $1.index, valeurString);
                            
                        }

                        bool abort = false;


                        if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                            int valeurExpression = $3.integerValue;
                            if(valeurExpression == 0){
                                abort = true;
                            }
                            int valeur = atoi(valeurString);
                            int result = valeur / valeurExpression;
                            sprintf(valeurString, "%d", result);

                        }else {
                            double valeurExpression = $3.floatValue;
                            double valeur = atof(valeurString);
                            if(valeurExpression == 0.0){
                                abort = true;
                            }
                            double result = valeur / valeurExpression;
                            sprintf(valeurString,"%.4f",result);

                        };
                        if(!abort){
                        char expressionValue[255];
                        if($3.isVariable){
                            strcpy(expressionValue , $3.nameVariable);
                        }else{
                            valeurToString($3, expressionValue);
                        }
                        if($1.symbole->type < simpleToArrayOffset){
                            setValeur($1.symbole, valeurString);
                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("DIV", $1.symbole->nom, expressionValue, $1.symbole->nom, qc));
                            }else{

                                insererQuadreplet(&q, "DIV", $1.symbole->nom, expressionValue, $1.symbole->nom, qc);
                                qc++;
                            }
                        }
                        else
                        {
                            setArrayElement($1.symbole, $1.index, valeurString);

                            char buff[255];
                            sprintf(buff, "%s[%d]", $1.symbole->nom, $1.index);
                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("DIV", buff, expressionValue, buff, qc));
                            }else{

                                    insererQuadreplet(&q, "DIV", buff, expressionValue, buff, qc);
                                    qc++;
                            }
                        }
                        }else{
                            yyerrorSemantic( "Division by zero");
                        }

                    }
                }
            }
            }
        }
    }
    | Variable MODEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                yyerrorSemantic( "Variable not initialized");
            }else{
                if($1.symbole->isConstant){
                yyerrorSemantic("Cannot reassign a value to a constant");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    yyerrorSemantic( "Type mismatch");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_INTEGER
                    && $1.symbole->type % simpleToArrayOffset != TYPE_FLOAT){
                        yyerrorSemantic( "Non numeric variable found");
                    }else{

                        char valeurString[255];

                        char buff[255];
                        char buff2[255];
                        char qcString[20];

                        char nom[255];
                        

                        if($1.symbole->type < simpleToArrayOffset){
                            getValeur($1.symbole, valeurString);
                            strcpy(nom, $1.symbole->nom);
                            }
                        else{
                            getArrayElement($1.symbole, $1.index, valeurString);
                            sprintf(nom, "%s[%d]", $1.symbole->nom, $1.index);
                            }

                        if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                            int valeurExpression = $3.integerValue;
                            int valeur = atoi(valeurString);
                            int result = valeur % valeurExpression;
                            sprintf(valeurString, "%d", result);

                            char expressionValue[255];

                            if($3.isVariable){
                                strcpy(expressionValue , $3.nameVariable);
                            }else{
                                valeurToString($3, expressionValue);
                            }

                            sprintf(buff2, "%s", expressionValue);
                            sprintf(buff, "%s", nom);
                            sprintf(qcString, "%s%d", "R",qc);

                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("DIV",buff, buff2,qcString, qc));
                            }else{
                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                qc++;
                            }
                            strcpy(buff, qcString);
                            sprintf(qcString, "%s%d", "R",qc);

                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("MUL",buff, buff2,qcString, qc +1));
                            }else{
                                insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                qc++;
                            }
                            strcpy(buff2, qcString);

                        }else {
                            double valeurExpression = $3.floatValue;
                            double valeur = atof(valeurString);
                            double result = fmod(valeur ,$3.floatValue);
                            sprintf(valeurString, "%.4f", result);

                            char expressionValue[255];

                            if($3.isVariable){
                                strcpy(expressionValue , $3.nameVariable);
                            }else{
                                valeurToString($3, expressionValue);
                            }

                            sprintf(buff2, "%s", expressionValue);
                            sprintf(buff, "%s", nom);
                            sprintf(qcString, "%s%d", "R",qc);

                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("DIV",buff, buff2,qcString, qc));
                            }else{
                                insererQuadreplet(&q, "DIV",buff, buff2,qcString, qc);
                                qc++;
                            }
                            strcpy(buff, qcString);
                            sprintf(qcString, "%s%d", "R",qc);

                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("MUL",buff, buff2,qcString, qc +1));
                            }else{
                                insererQuadreplet(&q, "MUL",buff, buff2,qcString, qc);
                                qc++;
                            }
                                strcpy(buff2, qcString);

                        };
                            if(isForLoop){
                                pushFifo(quadFifo, creerQuadreplet("SUB",nom, buff2,nom, qc +2));
                            }else{
                            insererQuadreplet(&q, "SUB",nom, buff2,nom, qc);
                            qc++;
                            }

                        if($1.symbole->type < simpleToArrayOffset)
                            {
                                setValeur($1.symbole, valeurString);
                            }
                        else
                            {
                                setArrayElement($1.symbole, $1.index, valeurString);
                            }
                    }
                }
            }
            }
        }
    }
    ;
    
Statement:
    DeclarationInitialisation SEMICOLUMN
    | Declaration SEMICOLUMN
    | Affectation SEMICOLUMN
    | Boucle
    | Condition
    ;
    
Condition:
    DebutIf ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE ConditionELSE
    ;
DebutIf : 
    IF PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE { // routine debut if
    // ici on est aprés la condition du if

    if($3.type == TYPE_BOOLEAN){
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc -1);	// this writes R to the r string
		insererQuadreplet(&q,"BZ","tmp", r, "",qc);
        // c'est ce qui est mis a jour au niveau
		// du else (branchement si t est egale a 0) r="Rqc" 
		//c'est le resultat de l'evaluation du condition
		empiler(stack,qc); // on sauvgarde l'addresse de cette quadreplet 
		qc++;
    }else{
        yyerrorSemantic( "Non boolean expression found");
    }
}
;
ConditionELSE:
    %empty { // routine fin if quand y a pas du else
        // ici on est a la fin de if et pas du else
        // on met a jour l'addresse de jump vers la fin de if 
        char adresse[10];
        sprintf(adresse,"%d",qc);
        int sauv = depiler(stack);// depiler pour avoir la derniere adresse
        // sauvgardee dans la pile et updater le branchement de if avec l'adresse de fin if
        updateQuadreplet(q,sauv,adresse);  // updater l'adresse de quadreplet crée au niveau du la routine if
    }
    | DebutElse Bloc ACCOLADEFERMANTE { // routine finElse
	// ici on est a la fin du else
    // on met a jour l'addresse de jump vers la fin de else 
    char adresse[10];
	sprintf(adresse,"%d",qc);
    int sauv = depiler(stack);// depiler pour avoir la derniere addresse
	// sauvgardee dans la pile et updater le branchement de else avec l'adresse debut de fin
	updateQuadreplet(q,sauv,adresse);  // updater l'adresse de quadreplet crée au niveau du routine else

}
;
DebutElse : ELSE ACCOLADEOUVRANTE { // routineElse
    // ici c'est le debut de else
	char adresse[10];
	sprintf(adresse,"%d",qc + 1);
    int sauv = depiler(stack);// depiler pour avoire la derniere addresse
    // sauvgardee dans la pile et updater le branchement de IF avec l'dresse debut de else
	updateQuadreplet(q,sauv,adresse);  // updater l'adresse de quadreplet crée au niveau du routine if
	insererQuadreplet(&q,"BR","temp","","",qc);
	empiler(stack,qc);
    qc++;
}
;

While:
    DebutWhile Bloc ACCOLADEFERMANTE { // routineFinWhile
    // ici c'est la fin du while
	char adresse[10];
    char adresseCondWhile [10];
    // on depile deux foix pour avoire l'addresse de condition du while pour se 
    // brancher vers la condition du while inconditionnelemnt (evaluer la condition pour la prochaine iteration)
    int sauvAdrDebutWhile = depiler(stack);//  c'est l'adr de debut while car c'est la derniere 
    // qui a ete empilé
    int sauvAdrCondWhile = depiler(stack); // l'adr de condition
    // on l'ecrit dans une chaine
    sprintf(adresseCondWhile,"%d",sauvAdrCondWhile);
    // on insert un quadreplet pour pour se brancher vers la condition du while
    insererQuadreplet(&q,"BR",adresseCondWhile,"","",qc);
    qc++;
    // updater l'adr du branchement vers la fin (le prochain bloc d'instructions) crée dans debut while
    sprintf(adresse,"%d",qc);
    updateQuadreplet(q,sauvAdrDebutWhile,adresse);
}
;
DebutWhile : 
    ConditionWhile Expression PARENTHESEFERMANTE  ACCOLADEOUVRANTE { //routineDebutWhile
    // ici c'est le debut de while
    if($2.type == TYPE_BOOLEAN){
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc);	// this writes R to the r string
		insererQuadreplet(&q,"BZ","tmp","",r,qc); // jump if condition returns false(0) 
        // to finWhile
		empiler(stack,qc); // on sauvgarde l'addresse de cette quadreplet pour updater le
        // quadreplet
		qc++;
    }else{
        yyerrorSemantic( "Non boolean expression found");
    }
}
;

ConditionWhile:
    WHILE PARENTHESEOUVRANTE { // routineCondWhile
    // ici on est avant la condition du while
    empiler(stack,qc); // on sauvgarde l'addresse de cette quadreplet 
    // it think it's qc-1 car on incrémonte le qc aprés l'insertion
}
;



For: 
    DebutFor Bloc  ACCOLADEFERMANTE  { // routineFinFor
    // ici c'est la fin du for
	char adresse[10];
    char adresseCondFor[10];
    // on ajoute le quadreplet généré dans affectation qui incrémente le compteur
    while(!fifoIsEmpty(quadFifo)){
        ajouterQuadreplet(&q, popFifo(quadFifo), qc);
        qc++;
    }
   
    // on depile deux foix pour avoir l'adresse de condition du for pour se 
    // brancher vers la condition du for inconditionnelemnt (evaluer la condition pour la prochaine iteration)
    int sauvAdrDebutFor = depiler(stack);//  c'est l'adr de debut de for car c'est la derniere 
    // qui a ete empilé
    int sauvAdrCondFor = depiler(stack); // l'adr de condition du For
    // on l'ecrit dans une chaine
    sprintf(adresseCondFor,"%d",sauvAdrCondFor);
    // on insert un quadreplet pour pour se brancher vers la condition du For inconditionnelemnt
    insererQuadreplet(&q,"BR",adresseCondFor, "","",qc);
    qc++;
    // updater l'adr du branchement vers la fin (le prochain bloc d'instructions) crée dans debut du For
    sprintf(adresse,"%d",qc);
    updateQuadreplet(q,sauvAdrDebutFor,adresse);

    
}
;

DebutFor: 
    ConditionFor Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE  { //routineDebutFor
// ici c'est le debut du for
    if($2.type == TYPE_BOOLEAN){ // normalemeent ça change à $6 quand on insert les routines
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc -1);	// this writes R to the r string
		insererQuadreplet(&q,"BZ","tmp",r, "",qc); // jump if condition returns false(0) 
        // to finFor (le prochain bloc d'instructions)
		empiler(stack,qc); // on sauvgarde l'addresse de cette quadreplet pour updater le
        // quadreplet apres avec l'adresse de finFor
		qc++;
        isForLoop = false;
    }else{
        yyerrorSemantic( "Non boolean expression found");
    }
}
;

ConditionFor : 
    FOR PARENTHESEOUVRANTE DeclarationInitialisation SEMICOLUMN { // routineCondFor 
    // ici on est avant l'expression de la condition du For
    empiler(stack,qc); // on sauvgarde l'addresse de cette quadreplet 
    // it think it's qc-1 car on incrémonte le qc aprés l'insertion
    //pour se brancher ici a la fin de l'iteration et reevaluer la condition
    isForLoop = true;
}
;
Boucle:
    While
    | For
    ;

Tableau: 
    ACCOLADEOUVRANTE Expression ACCOLADEFERMANTE {
        $$.type = $2.type + simpleToArrayOffset;
    
        char valeurString[255];
        valeurToString($2, valeurString);
        strcpy($$.tabValeur[0], valeurString);
        $$.length = 1;
    }
    | ACCOLADEOUVRANTE Expression ComaLoopExpression ACCOLADEFERMANTE {
        if($2.type == $3.type){
            
            // type of tableau is type of its content + simpleToArrayOffset
            $$.type = $2.type + simpleToArrayOffset;
            
            for(int i=0;i<$3.length;i++){
            strcpy($$.tabValeur[i], $3.tabValeur[i]);};

            $$.length = $3.length;

            char valeurString[255];
            valeurToString($2, valeurString);

            strcpy($$.tabValeur[$$.length], valeurString);
            $$.length += 1;
        } else {
            $$.type = -1;
            yyerrorSemantic( "Type mismatch");
        }
    }
    ;

ComaLoopExpression:
    COMA Expression {
        $$.type = $2.type;
        char valeurString[255];
        valeurToString($2, valeurString);
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
            valeurToString($2, valeurString);

            strcpy($$.tabValeur[$$.length], valeurString);
            $$.length += 1;
        }else{
            $$.type = -1;
        }
    }
    ;

Variable:
    ID {
        symbole * s = rechercherSymbole(tableSymboles, $1);
        if(s==NULL){
            yyerrorSemantic( "Unknown variable");
            $$.symbole = NULL;
        }else if(s->type >= simpleToArrayOffset){
            yyerrorSemantic( "Wrong array referencement syntax, did you mean ID[<index>]");
            $$.symbole = NULL;
        }else{
            $$.symbole = s;
            $$.index = -1;
        }
    }
    |ID CROCHETOUVRANT Expression CROCHETFERMANT {
        if($3.type != TYPE_INTEGER){
            yyerrorSemantic( "Non integer variable found");
            $$.symbole = NULL;
        }else{

            symbole * s = rechercherSymbole(tableSymboles, $1);
            if(s==NULL){
                yyerrorSemantic( "Unknown variable");
                $$.symbole = NULL;
            }else if(s->type < simpleToArrayOffset){
                yyerrorSemantic( "%s is not an array");
                $$.symbole = NULL;
            }else{
                    if($3.integerValue >= s->array->length )
                    yyerrorSemantic("Index out bounds");
                if($3.isVariable){
                    strcpy($$.indexString, $3.nameVariable);
                }else{
                    char indexString [20];
                    valeurToString($3, indexString);
                    strcpy($$.indexString, indexString);
                }
                $$.symbole = s;
                $$.index = $3.integerValue;
            }
        }
    }
    ;

%%

void yysuccess(char *s){
    currentColumn+=yyleng;
}

void yyerror(const char *s) {
    fprintf(stdout, "File '%s', line %d, character %d :"GREEN" %s "RESET"\n", file, yylineno, currentColumn, s);
    hasFailed = true;
}

void yyerrorSemantic(char *s){
    fprintf(stdout, "File '%s', line %d, character %d, ssemantic error: " RED " %s " RESET "\n", file, yylineno, currentColumn, s);
    hasFailed = true;
    return;
}

int main (void)
{
    // yydebug = 1;
    yyin=fopen(file, "r");
    if(yyin==NULL){
        printf("Erreur dans louverture du fichier\n");
        return 1;
    }

    stack = (pile *)malloc(sizeof(pile));
    quadFifo = initializeFifo();

    yyparse();  
    if (!hasFailed){

    afficherTableSymboles(tableSymboles);
    
    afficherQuad(q);
    }
    
    if(tableSymboles != NULL){
        free(tableSymboles);
    }

    free(stack);
    free(quadFifo);
    fclose(yyin);


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
    printf("^");


}