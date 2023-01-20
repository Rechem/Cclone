#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quadruplets.c"

void main(){
    quad * q = creerQuadreplet("+","a","b","R1",1);
    insererQuadreplet(q,"-","a","c","R2",2);
    insererQuadreplet(q,"*","R1","R2","R3",3);
    insererQuadreplet(q,"BR","etiq","","R3",4);
    insererQuadreplet(q,"-","d","e","R4",5);
    insererQuadreplet(q,"/","R2","R3","R5",6);
    afficherQuad(q);
    updateQuadreplet(q,4,"6");
    enregistrerQuad(q);
}