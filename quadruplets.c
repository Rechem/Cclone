#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quadruplets.h"

quad *creerQuadreplet(char opr[30],char op1[30],char op2[30],char res[30],int num){
    quad *q = (quad *)malloc(sizeof(quad));
    strcpy(q->operateur,opr);
    strcpy(q->operande1,op1);
    strcpy(q->operande2,op2);
    strcpy(q->resultat,res);
    q->qc=num;
    q->suivant=NULL;
    return q;
}

quad *insererQuadreplet(quad *p,char opr[],char op1[],char op2[],char res[],int num) {  
    quad *q;
    if(p==NULL){
        p=creerQuadreplet(opr,op1,op2,res,num);
        return p;
    }else{
    q = (quad *)malloc(sizeof(quad));
    strcpy(q->operateur,opr);
    strcpy(q->operande1,op1);
    strcpy(q->operande2,op2);
    strcpy(q->resultat,res);
    q->qc=num;
    q->suivant = p;
    p = q;
        return p;
    }
}

quad * ajouterQuadreplet(quad * q,quad * nouveauQuadreplet,int num){
    return insererQuadreplet(q,nouveauQuadreplet->operateur,nouveauQuadreplet->operande1,nouveauQuadreplet->operande2,nouveauQuadreplet->resultat,num);
}   

// mise a jour du quad numero qc dans le quad *(l'ensemble des quadreplets)
quad *updateQuadreplet(quad *q, int qc,char num[30]){
    quad *p = q;
    if (p==NULL){
        return q;
    }
    while(p!=NULL){
        if(p->qc==qc){
            strcpy(p->operande1,num);
            return p;
        }
        p=p->suivant;
    }
    return q;
}
void afficherQuad(quad *q)
{
    printf("\n<<<<<<<<<<  Affichage des quads  >>>>>>>>>>\n");
    if (q==NULL){
     printf("\n\n \t\t quad *Vide \n");
    }else{
    printf("**********************************************\n");
        while(q!=NULL){   
            printf("\t Quad[%d]=[ %s , %s , %s , %s ] \n",q->qc,q->operateur,q->operande1,q->operande2,q->resultat);
            q=q->suivant; 
        }
    }
    printf("**********************************************\n");
}

// ecrire le quad *dans un fichier
void enregistrerQuad(quad *q){
    FILE* fp;
    fp=fopen("quadruplets.txt","w");
    if(fp==NULL){
        printf("\n\n \t\t Erreur lors de l'ouverture du fichier\n");
    }
    if (q==NULL){
     printf("\n\n \t\t quad *Vide \n");
    }else{
        while(q!=NULL){   
            fprintf(fp,"Quad[%d]=[ %s , %s , %s , %s ] \n",q->qc,q->operateur,q->operande1,q->operande2,q->resultat);
            q=q->suivant; 
        }
    }
    fclose(fp);
}