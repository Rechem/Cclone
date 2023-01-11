#define TYPE_BOOLEAN 0
#define TYPE_INTEGER 1
#define TYPE_FLOAT 2
#define TYPE_STRING 3
// #define TYPE_ARRAY_BOOLEAN 4
// #define TYPE_ARRAY_INTEGER 5
// #define TYPE_ARRAY_FLOAT 6
// #define TYPE_ARRAY_STRING 7

//not sure if we wanna support arrays

typedef struct symbole symbole;
struct symbole{
    char nom[255];
    int type;
    char valeur[255];
    bool isConstant;
    struct symbole *suivant;
    // char tabValeur[1024][255];
};

//machine abstraite

symbole * _allouerSymbole();

void _mapTypeIntToChar(int type, char * typeChar);

symbole * creerSymbole(char * nom, int type, char * valeur, bool isConstant);

void insererSymbole(symbole * tableSymboles, symbole * nouveauSymbole);

void afficherTableSymboles(symbole * tableSymboles);

symbole * recherche(symbole * tableSymboles, char * nom);

void getNom(symbole * symbole, char * nom);

void getValeur(symbole * symbole, char * valeur);

int getType(symbole * symbole);

void getTypeChar(symbole * symbole, char * type);

void setValeur(symbole * symbole, char * valeur);
