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
#include "quadruplets.h"
#include "pile.h"
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

pile pile;
quad * q;
int qc = 1;
int isForLoop = 0;
quad * sauvAffectationFor;
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
    | Variable {
        if($1.symbole != NULL){
            char valeurString[255];
            if($1.symbole->type < simpleToArrayOffset){
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
                    }}else{
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
            }
            else
            {
                printf("Cannot find negatif of non boolean expression !\n");
            }
    }
    | SUB Expression {
            if($2.type != TYPE_STRING)
            {
                if($2.type == TYPE_INTEGER)
                {
                    $$.type=TYPE_INTEGER;
                    $$.integerValue=0-$2.integerValue;
                }
                else
                {
                    if($2.type == TYPE_FLOAT)
                    {
                        $$.type=TYPE_FLOAT;
                        $$.floatValue=0.0-$2.floatValue;
                    }
                }
            }
            else{
                printf("Cannot get negative of non numeric expression ! \n");
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
                printf("Cannot get negative of non numeric expression ! \n");
            }
    }
    | Expression ADD Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    printf("%d\n",$1.type);
                    if($1.type == TYPE_STRING)
                    {
                        strcpy($$.stringValue,$1.stringValue);
                        strcat($$.stringValue,$3.stringValue);
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue+$3.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue+$3.floatValue;
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
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression SUB Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue-$3.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue-$3.floatValue;
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression MUL Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $$.integerValue=$1.integerValue * $3.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $$.floatValue=$1.floatValue * $3.floatValue;
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
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression MOD Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        printf("Division on zero\n");
                    }
                    else
                    {
                        if($$.type == TYPE_STRING)
                        {
                            printf("Type mismatch\n");
                        }
                        else{
                            if($$.type == TYPE_INTEGER)
                            {
                                $$.integerValue=$1.integerValue % $3.integerValue;
                            }
                            else {
                                if($$.type == TYPE_FLOAT)
                                {
                                    $$.floatValue=fmod($1.floatValue,$3.floatValue);
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression DIV Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        printf("Division on zero\n");
                    }
                    else
                    {
                        if($$.type == TYPE_STRING)
                        {
                            printf("Type mismatch\n");
                        }
                        else{
                            if($$.type == TYPE_INTEGER)
                            {
                                $$.integerValue=$1.integerValue / $3.integerValue;
                            }
                            else {
                                if($$.type == TYPE_FLOAT)
                                {
                                    $$.floatValue=$1.floatValue / $3.floatValue;
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression POW Expression {
            if(($1.type == $3.type) && ($$.type == $1.type)){
                if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $$.integerValue=pow($1.integerValue,$3.integerValue);
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $$.floatValue=pow($1.floatValue,$3.floatValue);
                            }
                        }
                    }
            }
            else{
                printf("Type mismatch\n");
            }
    }
    | Expression ADDEQUALS Expression {
            if(($1.type == $3.type) && ($$.type == $1.type)){
                if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $1.integerValue=$1.integerValue + $3.integerValue;
                            $$.integerValue=$1.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $1.floatValue=$1.floatValue + $3.floatValue;
                                $$.floatValue=$1.floatValue;
                            }
                        }
                    }
            }
            else{
                printf("Type mismatch\n");
            }
    }
    | Expression SUBEQUALS Expression {
            if(($1.type == $3.type) && ($$.type == $1.type)){
                if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $1.integerValue=$1.integerValue - $3.integerValue;
                            $$.integerValue=$1.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $1.floatValue=$1.floatValue - $3.floatValue;
                                $$.floatValue=$1.floatValue;
                            }
                        }
                    }
            }
            else{
                printf("Type mismatch\n");
            }
    }
    | Expression MULEQUALS Expression {
            if(($1.type == $3.type) && ($$.type == $1.type)){
                if($$.type == TYPE_STRING)
                    {
                        printf("Type mismatch\n");
                    }
                    else{
                        if($$.type == TYPE_INTEGER)
                        {
                            $1.integerValue=$1.integerValue * $3.integerValue;
                            $$.integerValue=$1.integerValue;
                        }
                        else {
                            if($$.type == TYPE_FLOAT)
                            {
                                $1.floatValue=$1.floatValue * $3.floatValue;
                                $$.floatValue=$1.floatValue;
                            }
                        }
                    }
            }
            else{
                printf("Type mismatch\n");
            }
    }
    | Expression DIVEQUALS Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        printf("Division on zero\n");
                    }
                    else
                    {
                        if($$.type == TYPE_STRING)
                        {
                            printf("Type mismatch\n");
                        }
                        else{
                            if($$.type == TYPE_INTEGER)
                            {
                                $1.integerValue=$1.integerValue / $3.integerValue;
                                $$.integerValue=$1.integerValue;
                            }
                            else {
                                if($$.type == TYPE_FLOAT)
                                {
                                    $1.floatValue=$1.floatValue / $3.floatValue;
                                    $$.floatValue=$1.floatValue;
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression MODEQUALS Expression {
            if($1.type == $3.type){
                if($$.type == $1.type){
                    if((($3.type == TYPE_INTEGER) && ($3.integerValue == 0)) || (($3.type == TYPE_FLOAT) && ($3.floatValue == 0.0)))
                    {
                        printf("Division on zero\n");
                    }
                    else
                    {
                        if($$.type == TYPE_STRING)
                        {
                            printf("Type mismatch\n");
                        }
                        else{
                            if($$.type == TYPE_INTEGER)
                            {
                                $1.integerValue=$1.integerValue % $3.integerValue;
                                $$.integerValue=$1.integerValue;
                            }
                            else {
                                if($$.type == TYPE_FLOAT)
                                {
                                    $1.floatValue=fmod($1.floatValue,$3.floatValue);
                                    $$.floatValue=$1.floatValue;
                                }
                            }
                        }
                    }
                }
                else
                {
                    printf("Type mismatch\n");
                }
            }
            else
            {
                printf("Type mismatch\n");
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
                                }
                            }
                        }   
            }
            else
            {
                printf("Type mismatch\n");
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
                                }
                            }
                        }   
            }
            else
            {
                printf("Type mismatch\n");
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
                        }
                        else{
                            if($1.type == TYPE_INTEGER)
                            {
                                if($1.integerValue > $3.integerValue)
                                {
                                    $$.booleanValue=true;
                                    printf("%d\n",$$.booleanValue);
                                }
                                else{
                                    $$.booleanValue=false;
                                }
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
                                }
                            }
                        }   
            }
            else
            {
                printf("Type mismatch\n");
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
                                }
                            }
                        }   
            }
            else
            {
                printf("Type mismatch\n");
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
                            }
                        }   
            }
            else
            {
                printf("Type mismatch\n");
            }
    }
    | Expression AND Expression {
            if($1.booleanValue && $3.booleanValue)
            {
                $$.booleanValue=true;
            }
            else{
                $$.booleanValue=false;
            }
    }
    | Expression OR Expression {
            if($1.booleanValue || $3.booleanValue)
            {
                $$.booleanValue=true;
            }
            else{
                $$.booleanValue=false;
            }
    }

    
DeclarationInitialisation:
    Declaration EQUALS Expression {
        if($1 != NULL){
            if($1->type == $3.type){
                char valeurString[255];
                valeurToString($3, valeurString);
                setValeur($1, valeurString);

                insererQuadreplet(q, ":=", valeurString, "", $1.nom, qc);
                qc++;
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

                for(int i = 0; i< $3.length; i++){
                    char buff[255];
                    sprintf(buff, "%s[%d]", $1->nom, i);
                    insererQuadreplet(q, ":=", $3.tabValeur[i], "", "buff", qc);
                    qc++;
                };
            }else{
                printf("Type mismatch\n");
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
            printf("Identifiant deja declare : %s\n", $2);
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
            printf("Identifiant deja declare : %s\n", $3);
            $$ = NULL;
        }
    }
    |LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $6) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            if($4.type != TYPE_INTEGER || $4.integerValue < 1){
                printf("La dimension du tableau doit etre un entier positif\n");
            }else{
                symbole * nouveauSymbole = creerSymbole($6, $2 + simpleToArrayOffset, false, $4.integerValue);
                insererSymbole(&tableSymboles, nouveauSymbole);
                $$ = nouveauSymbole;

                char buff[255];
                strcpy(buff, $4.integerValue);
                insererQuadreplet(q, "BOUNDS","0", buff, "", qc);
                qc++;

                strcpy(buff, $4.integerValue);
                insererQuadreplet(q, "ADEC", $6, "", "", qc);
                qc++;
            };
        }else{
            printf("Identifiant deja declare : %s\n", $6);
            $$ = NULL;
        }
    }
    |CONST LIST SimpleType CROCHETOUVRANT Expression CROCHETFERMANT ID {
        if(rechercherSymbole(tableSymboles, $7) == NULL){
            // Si l'ID n'existe pas alors l'inserer
            if($5.type != TYPE_INTEGER || $5.integerValue < 1){
                printf("La dimension du tableau doit etre un entier positif\n");
            }else{
                symbole * nouveauSymbole = creerSymbole($7, $3 + simpleToArrayOffset, true, $5.integerValue);
                insererSymbole(&tableSymboles, nouveauSymbole);
                $$ = nouveauSymbole;

                char buff[255];
                strcpy(buff, $5.integerValue);
                insererQuadreplet(q, "BOUNDS","0", buff, "", qc);
                qc++;

                strcpy(buff, $5.integerValue);
                insererQuadreplet(q, "ADEC", $7, "", "", qc);
                qc++;
            };
        }else{
            printf("Identifiant deja declare : %s\n", $7);
            $$ = NULL;
        }
    }
    ;
    
Affectation:
    Variable EQUALS Expression { 
        if($1.symbole != NULL){
            if($1.symbole->type % simpleToArrayOffset != $3.type ){
                printf("Erreur sémantique : types non compatibles");
            }else{
                char valeurString[255];
                valeurToString($3,valeurString);
                if($1.symbole->type < simpleToArrayOffset)
                    setValeur($1.symbole, valeurString);
                else
                    setArrayElement($1.symbole, $1.index, valeurString);
            }
        }

    }        
    | Variable INC {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{

                    char valeurString[255];

                    if($1.symbole->type < simpleToArrayOffset)
                        getValeur($1.symbole, valeurString);
                    else
                        getArrayElement($1.symbole, $1.index, valeurString);

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
                        setValeur($1.symbole, valeurString);
                    else
                        setArrayElement($1.symbole, $1.index, valeurString);
                }
            }
        }
            
    }
    | Variable DEC {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)
                        getValeur($1.symbole, valeurString);
                    else
                        getArrayElement($1.symbole, $1.index, valeurString);

                    if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                        int valeur = atoi(valeurString);
                        valeur--;
                        sprintf(valeurString, "%d", valeur);
                    }else{
                        double valeur = atof(valeurString);
                        valeur--;
                        sprintf(valeurString,"%.4f",valeur);
                    };
                    if($1.symbole->type < simpleToArrayOffset)
                        setValeur($1.symbole, valeurString);
                    else
                        setArrayElement($1.symbole, $1.index, valeurString);
                }
            }
        }
    }     
    | Variable ADDEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)
                        getValeur($1.symbole, valeurString);
                    else
                        getArrayElement($1.symbole, $1.index, valeurString);

                    if($1.symbole->type % simpleToArrayOffset == TYPE_STRING){
                        strcat(valeurString,$3.stringValue);
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
                    if($1.symbole->type < simpleToArrayOffset)
                        setValeur($1.symbole, valeurString);
                    else
                        setArrayElement($1.symbole, $1.index, valeurString);
                }
            }
        }
    }   
    | Variable SUBEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                        printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                    }else{

                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)
                        getValeur($1.symbole, valeurString);
                    else
                        getArrayElement($1.symbole, $1.index, valeurString);

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
                    if($1.symbole->type < simpleToArrayOffset)
                        setValeur($1.symbole, valeurString);
                    else
                        setArrayElement($1.symbole, $1.index, valeurString);
                    }
                }
            }
        }
    }
    | Variable MULEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER
                    && $1.symbole->type % simpleToArrayOffset != TYPE_BOOLEAN){
                        printf("Erreur sémantique : cette variable nest pas de type entier ou réel ou boolean");
                    }else{

                    char valeurString[255];
                    
                    if($1.symbole->type < simpleToArrayOffset)
                        getValeur($1.symbole, valeurString);
                    else
                        getArrayElement($1.symbole, $1.index, valeurString);

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
                    if($1.symbole->type < simpleToArrayOffset)
                        setValeur($1.symbole, valeurString);
                    else
                        setArrayElement($1.symbole, $1.index, valeurString);
                    }
                }
            }
        }
    }
    | Variable DIVEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_FLOAT
                    && $1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                        printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                    }else{

                        char valeurString[255];

                        if($1.symbole->type < simpleToArrayOffset)
                            getValeur($1.symbole, valeurString);
                        else
                            getArrayElement($1.symbole, $1.index, valeurString);

                        if($1.symbole->type % simpleToArrayOffset == TYPE_INTEGER){
                            int valeurExpression = $3.integerValue;
                            int valeur = atoi(valeurString);
                            int result = valeur / valeurExpression;
                            sprintf(valeurString, "%d", result);
                        }else {
                            double valeurExpression = $3.floatValue;
                            double valeur = atof(valeurString);
                            double result = valeur / valeurExpression;
                            sprintf(valeurString,"%.4f",result);
                        };
                        if($1.symbole->type < simpleToArrayOffset)
                            setValeur($1.symbole, valeurString);
                        else
                            setArrayElement($1.symbole, $1.index, valeurString);
                    }
                }
            }
        }
    }
    | Variable MODEQUALS Expression {
        if($1.symbole != NULL){
            if(!$1.symbole->hasBeenInitialized){
                printf("Erreur sémantique : La variable n'a pas ete initialisee");
            }else{
                if($1.symbole->type % simpleToArrayOffset != $3.type){
                    printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                }else{
                    if($1.symbole->type % simpleToArrayOffset != TYPE_INTEGER){
                        printf("Erreur sémantique : cette variable nest pas de type entier ou réel");
                    }else{

                        char valeurString[255];
                        
                        if($1.symbole->type < simpleToArrayOffset)
                            getValeur($1.symbole, valeurString);
                        else
                            getArrayElement($1.symbole, $1.index, valeurString);

                        int valeurExpression = $3.integerValue;
                        int valeur = atoi(valeurString);
                        int result = valeur % valeurExpression;
                        sprintf(valeurString, "%d", result);

                        if($1.symbole->type < simpleToArrayOffset)
                            setValeur($1.symbole, valeurString);
                        else
                            setArrayElement($1.symbole, $1.index, valeurString);
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
    IF PARENTHESEOUVRANTE Expression PARENTHESEFERMANTE routineIf ACCOLADEOUVRANTE Bloc ACCOLADEFERMANTE ConditionELSE
    ;
routineIf:{
    // ici on est aprés la condition du if
    if($3.type == TYPE_BOOLEAN){
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc);	// this writes R to the r string
		q = insererQuadreplet(q,"BZ","tmp","",r,qc);
        // c'est ce qui est mis a jour au niveau
		// du else (branchement si t est egale a 0) r="Rqc" 
		//c'est le resultat de l'evaluation du condition
		empiler(&pile,qc); // on sauvgarde l'addresse de cette quadreplet 
		qc++;
    }else{
        printf("Erreur sémantique : cannot evaluate non boolean expression as condition");
    }
}
ConditionELSE: %empty
    | ELSE Condition 
    | ELSE ACCOLADEOUVRANTE routinElse Bloc ACCOLADEFERMANTE routineFinElse
    ;
routineElse:{
    // ici c'est le debut de else
	char adresse[10];
	sprintf(adresse,"%d",qc);
    int sauv = depiler(&pile);// depiler pour avoire la derniere addresse
	// sauvgardee dans la pile et updater le branchement de IF avec l'dresse debut de else
	q = updateQuadreplet(q,sauv,adresse);  // updater l'adresse de quadreplet crée au niveau du routine if
	q = insererQuadreplet(q,"BR","temp","","",qc);
	empiler(&pile,qc);
    qc++;
}
routineFinElse:{
	// ici on est a la fin du else
    // on met a jour l'addresse de jump vers la fin de else 
    char adresse[10];
	sprintf(adresse,"%d",qc);
    int sauv = depiler(&pile);// depiler pour avoire la derniere addresse
	// sauvgardee dans la pile et updater le branchement de else avec l'dresse debut de fin
	q = updateQuadreplet(q,sauv,adresse);  // updater l'adresse de quadreplet crée au niveau du routine else
    qc++;
}

While:
    WHILE PARENTHESEOUVRANTE routineCondWhile Expression PARENTHESEFERMANTE  ACCOLADEOUVRANTE routineDebutWhile Bloc ACCOLADEFERMANTE routineFinWhile
    ;
routineCondWhile : {
    // ici on est avant la condition du while
    empiler(&pile,qc-1); // on sauvgarde l'addresse de cette quadreplet 
    // it think it's qc-1 car on incrémonte le qc aprés l'insertion
}
routineDebutWhile{
    // ici c'est le debut de while
    if($4.type == TYPE_BOOLEAN){ // normalemeent ça change à 4 quand on insert la routine
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc);	// this writes R to the r string
		q = insererQuadreplet(q,"BZ","tmp","",r,qc); // jump if condition returns false(0) 
        // to finWhile
		empiler(&pile,qc); // on sauvgarde l'addresse de cette quadreplet pour updater le
        // quadreplet
		qc++;
    }else{
        printf("Erreur sémantique : cannot evaluate non boolean expression as condition");
    }
}

routineFinWhile : {
    // ici c'est la fin du while
	char adresse[10];
   
    // on depile deux foix pour avoire l'addresse de condition du while pour se 
    // brancher vers la condition du while inconditionnelemnt (evaluer la condition pour la prochaine iteration)
    int sauvAdrDebutWhile = depiler(&pile);//  c'est l'adr de debut while car c'est la derniere 
    // qui a ete empilé
    int sauvAdrCondWhile = depiler(&pile); // l'adr de condition
    // on l'ecrit dans une chaine
    sprintf(adresseCondWhile,"%d",sauvAdrCondWhile);
    // on insert un quadreplet pour pour se brancher vers la condition du while
    q = insererQuadreplet(q,"BR",adresseCondWhile,"","",qc);
    qc++;
    // updater l'adr du branchement vers la fin (le prochain bloc d'instructions) crée dans debut while
    sprintf(adresse,"%d",qc);
    q = updateQuadreplet(q,sauvAdrDebutWhile,adresse);
}

For: 
    FOR PARENTHESEOUVRANTE DeclarationInitialisation SEMICOLUMN routineCondFor Expression SEMICOLUMN Affectation PARENTHESEFERMANTE ACCOLADEOUVRANTE routineDebutFor Bloc routineFinFor ACCOLADEFERMANTE
    ;
routineCondFor : {
    // ici on est avant l'expression de la condition du For
    empiler(&pile,qc-1); // on sauvgarde l'addresse de cette quadreplet 
    // it think it's qc-1 car on incrémonte le qc aprés l'insertion
    //pour se brancher ici a la fin de l'iteration et reevaluer la condition
    isForLoop = 1;
}
routineDebutFor : {
// ici c'est le debut du for
    if($6.type == TYPE_BOOLEAN){ // normalemeent ça change à $6 quand on insert les routines
        char r[10]; // contien le resultat de l'expression de la condition
        sprintf(r,"R%d",qc);	// this writes R to the r string
		q = insererQuadreplet(q,"BZ","tmp","",r,qc); // jump if condition returns false(0) 
        // to finFor (le prochain bloc d'instructions)
		empiler(&pile,qc); // on sauvgarde l'addresse de cette quadreplet pour updater le
        // quadreplet apres avec l'adresse de finFor
		qc++;
    }else{
        printf("Erreur sémantique : cannot evaluate non boolean expression as condition");
    }
}
routineFinFor : {
    // ici c'est la fin du for
	char adresse[10];

    // on ajoute le quadreplet généré dans affectation qui incrémente le compteur
    q = ajouterQuadreplet(q,&sauvAffectationFor,qc);
    qc++;
   
    // on depile deux foix pour avoir l'adresse de condition du for pour se 
    // brancher vers la condition du for inconditionnelemnt (evaluer la condition pour la prochaine iteration)
    int sauvAdrDebutFor = depiler(&pile);//  c'est l'adr de debut de for car c'est la derniere 
    // qui a ete empilé
    int sauvAdrCondFor = depiler(&pile); // l'adr de condition du For
    // on l'ecrit dans une chaine
    sprintf(adresseCondFor,"%d",sauvAdrCondFor);
    // on insert un quadreplet pour pour se brancher vers la condition du For inconditionnelemnt
    q = insererQuadreplet(q,"BR",adresseCondFor,"","",qc);
    qc++;
    // updater l'adr du branchement vers la fin (le prochain bloc d'instructions) crée dans debut du For
    sprintf(adresse,"%d",qc);
    q = updateQuadreplet(q,sauvAdrDebutFor,adresse);
}
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
            printf("Le tableau doit contenir un seul type de donnees\n");
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
            printf("Variable inconnue: %s", $1);
            $$.symbole = NULL;
        }else if(s->type >= simpleToArrayOffset){
            printf("Mauvais referencement du tableau %s, voulez-vous dire %s[<index>]", $1, $1);
            $$.symbole = NULL;
        }else{
            $$.symbole = s;
            $$.index = -1;
        }
    }
    |ID CROCHETOUVRANT Expression CROCHETFERMANT {
        if($3.type != TYPE_INTEGER){
            printf("L'index doit etre un entier");
            $$.symbole = NULL;
        }else{

            symbole * s = rechercherSymbole(tableSymboles, $1);
            if(s==NULL){
                printf("Variable inconnue: %s", $1);
                $$.symbole = NULL;
            }else if(s->type < simpleToArrayOffset){
                printf("%s est une variable et non un tableau", $1);
                $$.symbole = NULL;
            }else{
                
                $$.symbole = s;
                $$.index = $3.integerValue;
            }
        }
    }
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