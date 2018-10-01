CC := gcc
CFLAGS := -Wall  -g #-Wextra
LIB := -lfl



all: etapa2

###############################################################################
# ETAPA 1
###############################################################################
etapa1:
	@flex scanner.l
	@$(CC) $(CFLAGS) lex.yy.c main.c $(LIB) -o etapa1


###############################################################################
# ETAPA 2
###############################################################################
etapa2:
	@bison -d -v parser.y 
	@flex --header-file=lex.yy.h scanner.l
	@$(CC) $(CFLAGS) -c lex.yy.c parser.tab.c $(LIB)
	@$(CC) $(CFLAGS) lex.yy.o parser.tab.o main.c $(LIB) -o etapa2

###############################################################################

clean:
	@rm -rf lex.yy.c lex.yy.h parser.tab.c parser.tab.h etapa1 etapa2 *.tgz *.o \
parser.output
