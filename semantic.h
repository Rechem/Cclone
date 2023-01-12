#include <stdbool.h>

typedef struct expression expression;
struct expression{
    int type;
    char stringValue[255];
    int integerValue;
    double floatValue;
    bool booleanValue;
    };


void valeurToString(expression * expression, char * valeur);