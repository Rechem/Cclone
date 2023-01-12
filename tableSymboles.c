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

        char type[255];
        getTypeChar(pointer, type);

        printf("\t%s", pointer->nom);
        printf("\t\t%s", type);
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
    if(symbole == NULL || valeur == NULL){
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
    strcpy(symbole->valeur, valeur);
}