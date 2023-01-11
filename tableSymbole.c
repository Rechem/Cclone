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
        return printf("Table des symboles est vide");
    }

    symbole * pointer = tableSymboles;

    printf("********************************************************************\n");
    printf("    ------------      ------        ----------          ----------  \n");
    printf("        Name           Type            Value             Constant   \n");
    printf("    ------------      ------        ----------          ----------  \n");

    while(pointer != NULL){  
        printf("       [%s]", pointer->nom);
        printf("       [%s]", pointer->type);
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
        return printf("No valeur type because NULL");
    }
    strncpy(valeur, symbole->valeur, sizeof(symbole->valeur));
}

int getReturnType(symbole * symbole){
    if(symbole == NULL){
        printf("No return type because NULL");    
        return -1;
    }

    return symbole->valeur;
}

void setValeur(symbole * symbole, char * valeur){
    if(symbole == NULL || valeur == NULL)
        return printf("Value non set because NULL");
    strncpy(symbole->valeur, valeur, sizeof(valeur));
}