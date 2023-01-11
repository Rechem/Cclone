cclone: analyseur.l syntaxique.y 
	flex -l analyseur.l 
	bison -d syntaxique.y 
	gcc syntaxique.tab.c tableSymbole.c lex.yy.c -lm -lfl -o test.exe