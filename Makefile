CC := gcc
CFLAGS := -Wall -Wextra -g
LIB := -lfl



all: etapa1 etapa2

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
	@bison -dv parser.y 
	@flex scanner.l
	@$(CC) $(CFLAGS) -c lex.yy.c parser.tab.c $(LIB)
	@$(CC) $(CFLAGS) lex.yy.o parser.tab.o main.c $(LIB) -o etapa2

###############################################################################

clean:
	@rm -rf lex.yy.c parser.tab.c parser.tab.h etapa1 etapa2 *.tgz *.o \
parser.output
