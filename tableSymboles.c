#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "tableSymboles.h"

symbole * _allouerSymbole(){
    symbole * pointer = (symbole *) malloc(sizeof(symbole));
    return pointer;
}

symbole * creerSymbole(char * nom, int type, bool isConstant){
    symbole * pointer = _allouerSymbole();
    
    strcpy(pointer->nom, nom);
    pointer->type = type;
    pointer->isConstant = isConstant;
    pointer->hasBeenInitialized = false;
    if(type >=4){
        pointer->array = (arraySubSymbol *) malloc(sizeof(arraySubSymbol));
    }
    return pointer;
}

void insererSymbole(symbole ** tableSymboles, symbole * nouveauSymbole){
    if(nouveauSymbole == NULL)
        return;

    if (tableSymboles != NULL){
        nouveauSymbole->suivant = *tableSymboles;
    }

    *tableSymboles = nouveauSymbole;

}

void afficherTableSymboles(symbole * tableSymboles){

    if(tableSymboles == NULL){
        printf("Table des symboles est vide");
        return;
    }

    symbole * pointer = tableSymboles;

    printf("************************ TABLE DES SYMBOLES ************************\n");
    printf("--------------------------------------------------------------------\n");
    printf("\tName\t\tType\t\tValue\t\tConstant   \n");

    while(pointer != NULL){  
    printf("--------------------------------------------------------------------\n");

        char type[COLS];
        getTypeChar(pointer, type);

        printf("\t%s", pointer->nom);
        printf("\t\t%s", type);
        if(pointer->type >= 4 ){
            printf("\t[");
            if(pointer->array->length > 0)
                printf("%s", pointer->array->tabValeur[pointer->array->length-1]);

            for (int i = pointer->array->length -2; i >=0; i--){
                printf(", %s", pointer->array->tabValeur[i]);
            }
            printf("]");
        }else
            printf("\t\t%s", pointer->valeur);
        printf("\t\t%s\n", pointer->isConstant ? "Oui" : "Non");
        pointer=pointer->suivant;
    }

    printf("********************************************************************\n");
}

symbole * rechercherSymbole(symbole * tableSymboles, char * nom){

    if(tableSymboles == NULL || nom == NULL){
        return NULL;
    }
    
    symbole * pointer = tableSymboles;

    while(pointer!=NULL){
        if (!strcmp(pointer->nom, nom)){
            return pointer;
        }
        pointer = pointer->suivant;
    }
    return NULL;
    
}

void getNom(symbole * symbole, char * nom){
    if(symbole == NULL || nom == NULL){
        printf("No nom type because NULL");
        return;
    }
    strcpy(nom, symbole->nom);
}

void getValeur(symbole * symbole, char * valeur){
    if(symbole == NULL || !symbole->hasBeenInitialized || valeur == NULL){
        printf("No valeur type because NULL");
        return;
    }
    strcpy(valeur, symbole->valeur);
}

int getType(symbole * symbole){
    if(symbole == NULL){
        printf("No type because NULL");    
        return -1;
    }

    return symbole->type;
}

void _mapTypeIntToChar(int type, char * typeChar){
    if(typeChar == NULL)
        return;

    switch (type){
        case TYPE_INTEGER:
            sprintf(typeChar, "%s", "Integer");
            break;
        case TYPE_FLOAT:
            sprintf(typeChar, "%s", "Float");
            break;
        case TYPE_STRING:
            sprintf(typeChar, "%s", "String");
            break;
        case TYPE_BOOLEAN:
            sprintf(typeChar, "%s", "Boolean");
            break;
        case TYPE_ARRAY_BOOLEAN:
            sprintf(typeChar, "%s", "Boolean[]");
            break;
        case TYPE_ARRAY_FLOAT:
            sprintf(typeChar, "%s", "Float[]");
            break;
        case TYPE_ARRAY_INTEGER:
            sprintf(typeChar, "%s", "Integer[]");
            break;
        case TYPE_ARRAY_STRING:
            sprintf(typeChar, "%s", "String[]");
            break;
        default:
            break;
    }
}

void getTypeChar(symbole * symbole, char * type){
    if(symbole == NULL || type == NULL){
        printf("No char type because NULL");
        return;
    }

    _mapTypeIntToChar(symbole->type, type);

}

//change it to adapt to arrays
void setValeur(symbole * symbole, char * valeur){

    if(symbole == NULL){
        printf("Value not set because symbole is NULL");
        return;
    }

    if(symbole->hasBeenInitialized && symbole->isConstant){
        printf("Can't reassign a vlue to a constant");
        return;
    }

    if(symbole->type <= 3)
        strcpy(symbole->valeur, valeur);
    else{
        printf("Can't assign simple type to array\n");
    }
    symbole->hasBeenInitialized = true;

}

void setTabValeur(symbole * symbole, char tabValeur[ROWS][COLS], int length){
    if(symbole == NULL){
        printf("Value not set because symbole is NULL");
        return;
    }

    if(symbole->hasBeenInitialized && symbole->isConstant){
        printf("Can't reassign a vlue to a constant");
        return;
    }

    if(symbole->type >= 4){
        for(int i=0;i<length;i++){
         strcpy(symbole->array->tabValeur[i], tabValeur[i]);
        }
        symbole->array->length = length;
    }else{
        printf("Can't assign array to simple type\n");
    }
    symbole->hasBeenInitialized = true;
}

void getArrayElement(symbole * symbole, int index, char * valeur){
    if(symbole == NULL || symbole->type <= 3 || !symbole->hasBeenInitialized
    || valeur== NULL || index < 0){
        printf("No valeur type because NULL");
        return;
    }
    strcpy(valeur, symbole->array->tabValeur[index]);
}