%{
int yylex(void);
void yyerror (char const *s);
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

%%

programa: 
	element
;

element: 
	global_variavel_decla element
	| novos_tipos_decla element
	| funcoes element
	| %empty
;

funcoes: 
	static_opcional tipo TK_IDENTIFICADOR lista_parametros bloco
;  

lista_parametros: 
	parametro ',' lista_parametros
	| parametro
;

parametro:
	const_opcional tipo TK_IDENTIFICADOR
;

bloco: 
	'{' comandos '}'
;

comandos: 
	comando comandos
	| comando
;

comando: 
	local_variavel_decla
	| atribuicao
	| entrada_saida_retorno
	| chamada_funcao
	| bloco
	| fluxo_controle
;

local_variavel_decla: 
	static_opcional const_opcional tipo TK_IDENTIFICADOR
	| static_opcional const_opcional tipo TK_IDENTIFICADOR TK_OC_LE literal
;

literal:
	TK_LIT_INT
	| TK_LIT_FLOAT
	| TK_LIT_FALSE
	| TK_LIT_TRUE
	| TK_LIT_CHAR
	| TK_LIT_STRING
;

atribuicao:
	atribuicao_primitivo
	| atribuicao_tipo_usuario
;

atribuicao_primitivo:
	TK_IDENTIFICADOR '=' expressao
	| '[' expressao ']' '=' expressao
;

atribuicao_tipo_usuario:
	TK_IDENTIFICADOR '$' campo '=' expressao
	| '[' expressao ']' '$' campo '=' expressao
;

entrada_saida_retorno:
	TK_PR_INPUT expressao
	|TK_PR_OUTPUT lista_expressao
;

lista_expressao: 
	expressao ',' lista_expressao
	| expressao
;

chamada_funcao: 
	TK_IDENTIFICADOR '(' lista_argumentos ')'
;

lista_argumentos:
	argumento ',' lista_argumentos
	| argumento
;

argumento:
	expressao
	| '.'
;
// -> numero = inteiro?
shift: 
	TK_IDENTIFICADOR shift_simbol literal
	| TK_IDENTIFICADOR '$' campo shift_simbol literal
	| TK_IDENTIFICADOR '[' expressao ']' shift_simbol literal
	| TK_IDENTIFICADOR '[' expressao ']' '$' campo shift_simbol literal
	| TK_IDENTIFICADOR shift_simbol expressao
	| TK_IDENTIFICADOR '$' campo shift_simbol expressao
	| TK_IDENTIFICADOR '[' expressao ']' shift_simbol expressao
	| TK_IDENTIFICADOR '[' expressao ']' '$' campo shift_simbol expressao
;

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


fluxo_controle: 
	TK_PR_IF '(' expressao ')' TK_PR_THEN bloco
	| TK_PR_IF '(' expressao ')' TK_PR_THEN bloco TK_PR_ELSE bloco
	| TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_expressao ')' bloco
	| TK_PR_FOR '(' lista_comandos ':' expressao ':' lista_comandos ')' bloco
	| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco
	| TK_PR_DO bloco TK_PR_WHILE '(' expressao ')'
;

expressao: 
	exp_aritmetica
	| exp_logica
	| exp_pipes
;

exp_aritmetica:
	operador_exp_arit
	| operandor_unario_opcional operando_exp_arit_bin operandor_unario_opcional exp_aritmetica
	| operando_exp_arit operador_exp_arit '(' exp_aritmetica ')'
	| "falta coisa"
;

operando_exp_arit:
	TK_IDENTIFICADOR
	| TK_IDENTIFICADOR '[' exp_inteira ']'
	| TK_LIT_INT
	| TK_LIT_FLOAT
	| chamada_funcao
;

operandor_unario_opcional:
	'+'	
	| '-'
	| '*'
	| '!'
	| '?'
	| '#'
	| '&'
	| %empty
;

operador_exp_arit_bin:
	'+'	
	| '-'
	| '*'
	| '/'
	| '%'
	| '|'
	| '^'
	| '&'
	| operador_relacional
;

exp_logica:
	operando_exp_arit operador_relacional operando_exp_arit

	| operando_logico operador_logico operando_logico

;
// TO DO: Nesta etapa do trabalho não há distinção entre os tipos de expressões.
operando_logico:
	exp_logica
	| TK_PR_FALSE
	| TK_PR_TRUE

operador_relacional:
	"=="
	| ">="
	| "<="
	| "!="
	| '>'
	| '<'
;

operador_logico:
	"&&"
	| "||"
	| '!'
;

campo: 
	"campo"
;

global_variavel_decla: 
	"GVD"
;

novos_tipos_decla: 
	"NTD"
;

tipo: 
	 TK_PR_FLOAT
	| TK_PR_BOOL
	| TK_PR_CHAR
	| TK_PR_STRING
	| TK_PR_INT
;

static_opcional: 
	TK_PR_STATIC
	| %empty
	;

const_opcional:
	TK_PR_CONST
	| %empty
;
%%
