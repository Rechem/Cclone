cclone: analyseur.l syntaxique.y 
	flex -l analyseur.l 
	bison -d syntaxique.y 
	gcc lex.yy.c syntaxique.tab.c semantic.c tableSymboles.c -lm -lfl -o test.exe