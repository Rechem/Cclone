#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "tableSymboles.h"

symbole * _allouerSymbole(){
    symbole * pointer = (symbole *) malloc(sizeof(symbole));
    return pointer;
}

symbole * creerSymbole(char * nom, int type, char * valeur, bool isConstant){
    symbole * pointer = _allouerSymbole();
    strncpy(pointer->nom, nom, sizeof(nom));
    pointer->type = type;
    strncpy(pointer->valeur, valeur, sizeof(valeur));
    pointer->isConstant = isConstant;
    return pointer;
}

void insererSymbole(symbole * tableSymboles, symbole * nouveauSymbole){
    if (tableSymboles != NULL){
        nouveauSymbole->suivant = tableSymboles;
    }

    tableSymboles = nouveauSymbole;

}

void afficherTableSymboles(symbole * tableSymboles){

    if(tableSymboles == NULL){
        printf("Table des symboles est vide");
        return;
    }

    symbole * pointer = tableSymboles;

    printf("********************************************************************\n");
    printf("    ------------      ------        ----------          ----------  \n");
    printf("        Name           Type            Value             Constant   \n");
    printf("    ------------      ------        ----------          ----------  \n");

    while(pointer != NULL){  

        char type[255];
        getTypeChar(pointer, type);

        printf("       [%s]", pointer->nom);
        printf("       [%s]", type);
        printf("       [%s]", pointer->valeur);
        pointer=pointer->suivant;
    }

    printf("******************************************\n");
}

symbole * recherche(symbole * tableSymboles, char * nom){

    if(tableSymboles == NULL || nom == NULL){
        printf("No recherche because NULL");
        return NULL;
    }
    
    symbole * pointer = tableSymboles;

    while(pointer!=NULL){
        if (strcmp(pointer->nom, nom)){
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
    strncpy(nom, symbole->nom, sizeof(symbole->nom));
}

void getValeur(symbole * symbole, char * valeur){
    if(symbole == NULL || valeur == NULL){
        printf("No valeur type because NULL");
        return;
    }
    strncpy(valeur, symbole->valeur, sizeof(symbole->valeur));
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

void setValeur(symbole * symbole, char * valeur){
    if(symbole == NULL || valeur == NULL){
        printf("Value non set because NULL");
        return;
    }
    strncpy(symbole->valeur, valeur, sizeof(valeur));
}