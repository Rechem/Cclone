#include <stdbool.h>

typedef struct expression expression;
struct expression{
    int type;
    char stringValue[255];
    int integerValue;
    double floatValue;
    bool booleanValue;
};

typedef struct tableau tableau;
struct tableau{
    int type;
    int length;
    char tabValeur[128][32];
};


void valeurToString(expression * expression, char * valeur);