%{
#include <stdio.h>
#include "lex.yy.h"

int yylex(void);

void yyerror (char const *s);
extern int get_line_number();
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

//mais um teste aqui
%left '+'
%left '-'
%left '/'

%right TK_IDENTIFICADOR

%right '&'
//%left '*'
%right '*'
%right '#'


%union {
  comp_dict_item_t *valor_lexico;
  comp_tree_t *nodo_arvore;
  int type;
}

%%

program: 
	code
	| %empty
;

code:
	element
	| element code 
;

element: 	
	global_variavel_decla ';' 	//{$$ = $2;}
	| novos_tipos_decla ';' 	//{$$ = $2;}
	| funcoes  		//{$$ = $2;}
;


global_variavel_decla: 
	TK_IDENTIFICADOR static_opcional tipo  
	| TK_IDENTIFICADOR '[' TK_LIT_INT ']' static_opcional tipo 
;

static_opcional: 
	TK_PR_STATIC
	| %empty
;

const_opcional:
	TK_PR_CONST
	| %empty
;

tipo : 
	tipo_primitivo 
	| TK_IDENTIFICADOR
;

tipo_primitivo:
	TK_PR_INT
	| TK_PR_FLOAT
	| TK_PR_BOOL
	| TK_PR_CHAR
	| TK_PR_STRING
;

novos_tipos_decla: 
	TK_PR_CLASS TK_IDENTIFICADOR '[' lista_campos ']' 
;

lista_campos:
	encapsulamento tipo_primitivo TK_IDENTIFICADOR ':' lista_campos
	| encapsulamento tipo_primitivo TK_IDENTIFICADOR
;

encapsulamento:
	TK_PR_PRIVATE
	| TK_PR_PROTECTED
	| TK_PR_PUBLIC
;

funcoes: 
	header '(' lista_parametros ')' bloco //{$$ = cria_nodo_ternario(NULL, $1, $3, $5);} ctz que isso tá errado, tem que começar nas folhas
	| header '(' ')' bloco
 ;  

header:
	static_opcional tipo TK_IDENTIFICADOR //{$$ = cria_nodo_ternario(NULL, $1, $3, $5);} 
;
lista_parametros: 
	parametro ',' lista_parametros 	//{$$ = cria_nodo_ternario(NULL, $1, $3, $5);} 
	| parametro 			//{$$ = cria_nodo_unario(NULL, $1, $3, $5);} 
;

parametro:
	const_opcional tipo TK_IDENTIFICADOR			{}
	| const_opcional TK_IDENTIFICADOR TK_IDENTIFICADOR	{}
;


// marcador 1


bloco: 
	'{' comandos '}'
	| '{'  '}'
;

comandos: 
	comando ';' comandos
	| comando ';'
;

comando: 

	local_variavel_decla
	| atribuicao
	| entrada_saida
	| retorno
	| chamada_funcao
	| shift 
	| bloco 
	| fluxo_controle
	| case 
	| break
	| continue
;

local_variavel_decla: 
	static_opcional const_opcional tipo TK_IDENTIFICADOR
	| static_opcional const_opcional tipo_primitivo TK_IDENTIFICADOR TK_OC_LE literal
	| static_opcional const_opcional tipo_primitivo TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
	
;

/// marcador 2

literal:
	operando_exp_arit_literal
	| TK_LIT_FALSE
	| TK_LIT_TRUE
	| TK_LIT_CHAR
	| TK_LIT_STRING
;

operando_exp_arit_literal:
	TK_LIT_INT
	| TK_LIT_FLOAT
;


atribuicao:
	atribuicao_primitivo
	| atribuicao_tipo_usuario
;

atribuicao_primitivo:
	TK_IDENTIFICADOR '=' expressao
	| TK_IDENTIFICADOR '[' expressao ']' '=' expressao
;

atribuicao_tipo_usuario:
	TK_IDENTIFICADOR '$' campo '=' expressao
	| TK_IDENTIFICADOR '[' expressao ']' '$' campo '=' expressao
;

campo: 
	TK_IDENTIFICADOR
;


/// marcador 3

chamada_funcao: 
	TK_IDENTIFICADOR '(' lista_argumentos ')'
	| TK_IDENTIFICADOR '(' ')'
;

lista_argumentos:
	argumento ',' lista_argumentos
	| argumento
;

argumento:
	expressao
	| '.'
;

shift: 
	TK_IDENTIFICADOR shift_simbol expressao
	| TK_IDENTIFICADOR '$' campo shift_simbol expressao
	| TK_IDENTIFICADOR '[' expressao ']' shift_simbol expressao
	| TK_IDENTIFICADOR '[' expressao ']' '$' campo shift_simbol expressao
;
// shift: 
//	TK_IDENTIFICADOR shift_simbol TK_LIT_INT
//	| TK_IDENTIFICADOR '$' campo shift_simbol TK_LIT_INT
//	| TK_IDENTIFICADOR '[' expressao ']' shift_simbol TK_LIT_INT
//	| TK_IDENTIFICADOR '[' expressao ']' '$' campo shift_simbol TK_LIT_INT
//;  //EXPRESSAO PODE SER UM LITERAL INTEIRO

shift_simbol:
	TK_OC_SL
	| TK_OC_SR
;

retorno:
	TK_PR_RETURN expressao ';'
;

break:
	TK_PR_BREAK ';'
;

continue:
	TK_PR_CONTINUE ';'
;

case:
	TK_PR_CASE TK_LIT_INT ':'
;

entrada_saida:
	TK_PR_INPUT expressao
	| TK_PR_OUTPUT lista_expressao
;


fluxo_controle: 
	TK_PR_IF '(' expressao ')' TK_PR_THEN bloco
	| TK_PR_IF '(' expressao ')' TK_PR_THEN bloco TK_PR_ELSE bloco
	
	| TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_expressao ')' bloco
	
	| TK_PR_FOR '(' lista_comandos ':' expressao ':' lista_comandos ')' bloco
	
	| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco
	
	| TK_PR_DO bloco TK_PR_WHILE '(' expressao ')'
	
	| TK_PR_SWITCH '(' expressao ')' bloco
;

lista_expressao: 
	expressao ',' lista_expressao
	| expressao
;

lista_comandos:
	comando_for ',' lista_comandos ';' 
	| comando_for ';'
;

comando_for:
	local_variavel_decla
	| atribuicao
	| retorno
	| chamada_funcao
	| shift 
	| bloco 
	| fluxo_controle
	| break
	| continue
;

///marcador 4 -exp
expressao: 
	exp_aritmetica
	| exp_logica
	| exp_pipes
	| exp_ternaria
;

exp_aritmetica:
	expressao_unaria
	| expressao_unaria operador_exp_arit  exp_aritmetica //recurs 
	| '(' exp_aritmetica ')'
;

expressao_unaria:
	operando
	| operador_unario expressao_unaria
;

operando:
	TK_IDENTIFICADOR
	| TK_IDENTIFICADOR '[' expressao ']' // nao era pra ser " '[' exp_inteira ']' " ?
	| literal
	| chamada_funcao
;

operador_unario:
	'+'	
	| '-'
	| '*'
	| '!'
	| '?'
	| '#'
	| '&'
;

operador_exp_arit:
	'+'	
	| '-'
	| '*'
	| '/'
	| '%'
	| '|'
	| '^'
	| '&'
;

/// marcador 5 : log
exp_logica:
	exp_aritmetica operador_relacional exp_aritmetica
	| expressao operador_logico expressao 
	| '(' exp_logica ')'

;

operador_relacional:
	TK_OC_EQ
	| TK_OC_GE
	| TK_OC_LE
	| TK_OC_NE
	| '>'
	| '<'
;

operador_logico:
	TK_OC_AND
	| TK_OC_OR
	| '!'
;

///marcador 6 -pipe
exp_pipes:
	chamada_funcao operador_pipe exp_pipes
	| chamada_funcao operador_pipe chamada_funcao
;

operador_pipe:
	TK_OC_FORWARD_PIPE
	| TK_OC_BASH_PIPE
;

///marcador 7

exp_ternaria:
	"exp" ':' "exp" '?' "exp"
	| '(' exp_ternaria ')'
;

%%


void yyerror (const char *s) {
	char mensagem_erro[] = "Erro no token: %s na linha %d. Sintaxe ou Overflow? %s\n";
	fprintf(stderr, mensagem_erro, yytext, get_line_number(), s);
}
