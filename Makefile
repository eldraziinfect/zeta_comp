# Baseado em
# UFRGS - Compiladores B - Marcelo Johann - 2009/2 - Etapa 1
#
# Makefile for two compiler calls
# The  code generated by lex and main.c are separately compiled
# You must include lex.yy.h in your main as well as the definition of
# other interfaces like getLineNumber, initMe, running...
# Use make clean to remove old files before remaking everything
#
etapa2: parser.y
	bison -d parser.y -o etapa2
etapa1: lex.yy.o main.o
	gcc -o etapa1 lex.yy.o main.o -lfl
main.o: main.c
	gcc -c main.c -lfl
lex.yy.o: lex.yy.c
	gcc -c lex.yy.c -lfl
lex.yy.c: scanner.l
	flex --header-file=lex.yy.h scanner.l 
clean:
	rm *.o lex.yy.c
