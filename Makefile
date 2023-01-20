cclone: analyseur.l syntaxique.y 
	flex -l analyseur.l 
	bison -d syntaxique.y 
	gcc lex.yy.c syntaxique.tab.c quadruplets.c pile.c list.c semantic.c tableSymboles.c -lm -lfl -o test.exe