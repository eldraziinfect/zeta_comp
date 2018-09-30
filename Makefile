#Makefile for Zeta_Comp João Vicente, Luis Miguel 2018-2


etapa2: 
	bison -d -v parser.y
	flex --header-file=lex.yy.h scanner.l
	gcc -c lex.yy.c parser.tab.c -lfl
	gcc parser.tab.o lex.yy.o main.c -o etapa2 -lfl
clean:
	rm *.o lex.yy.h parser.output parser.tab.c parser.tab.h 
