/* 
	Grupo Nu:
		Arthur Marques Medeiros - 261587
		Luiz Miguel Krüger - 228271
*/

%code requires {
#include "main.h"
#include "cc_tree.h"
}

%{
#include "main.h"
#include "string.h"

extern comp_dict_t *table;
extern comp_tree_t *syntaxTree;
extern comp_dict_item_t *remainderArgs;
extern char *ilocOutput;
int currentLabel = 0;
int currentRegister = 0;
extern int currentRegSize;
char *breakLabel = NULL;
FILE *fp = NULL;

void printOperation (operation_list_t *op_l);
comp_tree_t *fazNodo (int id, comp_dict_item_t *tableEntry);
void conectaNodo (comp_tree_t *pai, comp_tree_t *filho);
int validaExpression(comp_tree_t *nodo);
operation_list_t *criaCodigoFromTree(comp_tree_t *nodo, int isMain);
operation_list_t *iniciaCodigoFromTree(comp_tree_t *nodo);

%}

/* Declaração dos tokens da linguagem */
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
%token TK_OC_OOR
%token TK_OC_PIP
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

%left '+'
%left '-'
%left '*'
%left '/'

%type <nodo_arvore> Element
%type <nodo_arvore> FunDeclaration
%type <valor_lexico> Header
%type <nodo_arvore> CommandBlock
%type <valor_lexico> TK_IDENTIFICADOR
%type <nodo_arvore> Commands
%type <nodo_arvore> Command
%type <nodo_arvore> VarDeclaration
%type <nodo_arvore> FunctionCall
%type <nodo_arvore> Attribution 
%type <nodo_arvore> Input
%type <nodo_arvore> Output 
%type <nodo_arvore> ShiftExp
%type <nodo_arvore> Return
%type <nodo_arvore> Break 
%type <nodo_arvore> Continue 
%type <nodo_arvore> If	
%type <nodo_arvore> While		
%type <nodo_arvore> For		
%type <nodo_arvore> ForEach	
%type <nodo_arvore> Switch
%type <nodo_arvore> PipeExpr
%type <nodo_arvore> Expression
%type <nodo_arvore> AritExpr
%type <nodo_arvore> Operands
%type <nodo_arvore> ArraySizeExp
%type <nodo_arvore> Literal
%type <nodo_arvore> CallParams
%type <valor_lexico> TK_LIT_INT
%type <valor_lexico> TK_LIT_FLOAT
%type <valor_lexico> TK_LIT_FALSE
%type <valor_lexico> TK_LIT_TRUE
%type <valor_lexico> TK_LIT_CHAR
%type <valor_lexico> TK_LIT_STRING
%type <nodo_arvore> VarDeclaration1
%type <nodo_arvore> VarDeclaration2
%type <nodo_arvore> RightAttr
%type <nodo_arvore> LogExpr
%type <nodo_arvore> OutputList
%type <nodo_arvore> ForList
%type <nodo_arvore> PipeRecursion
%type <nodo_arvore> PipeTokens
%type <nodo_arvore> CommandFor
%type <nodo_arvore> ForEachList
%type <nodo_arvore> NewLogExpr
%type <nodo_arvore> Case
%type <type> PrimType
%type <type> Type
%type <type> Static
%type <type> Const
%type <type> ArraySize
%type <valor_lexico> EntryParams

%union {
  comp_dict_item_t *valor_lexico;
  comp_tree_t *nodo_arvore;
  int type;
}

%%
/* Regras (e ações) da gramática */


programa: Element     {syntaxTree = fazNodo(AST_PROGRAMA, NULL); conectaNodo(syntaxTree, $1); operation_list_t *code = iniciaCodigoFromTree($1); fp = fopen (ilocOutput, "w"); printOperation(code); fclose(fp);}
;

Element: GVarDeclaration Element   {$$ = $2;}
| TypeDeclaration Element	{$$ = $2;}
| FunDeclaration Element 	{conectaNodo($1, $2); $$ = $1;}
| %empty 		{$$ = NULL;}
;

FunDeclaration: Header CommandBlock	{$$ = fazNodo(AST_FUNCAO, $1); conectaNodo($$, $2); table_values_t *entry = ((table_values_t *) ($1->value)); entry->regSizeFun = currentRegSize;}
;

Header: Static Type TK_IDENTIFICADOR '(' EntryParams ')' {	$$ = $3;
															table_values_t *entry = ((table_values_t *) ($3->value));
															char *name = (char *) entry->tokenvalue;
															if (isInTable(name) == 1 && entry->identType != -1) quit(IKS_ERROR_DECLARED, "Identificador redeclarado.");
															else entry->identType = $2 + 6;
															arg_list_t *func_arg_list = (arg_list_t *) malloc (sizeof(arg_list_t));
															func_arg_list->next = NULL;
															comp_dict_item_t *cur_arg = $5;
															arg_list_t *cur_aux = func_arg_list;
															while (cur_arg != NULL) {
																cur_aux->type = ((table_values_t *) cur_arg->value) -> identType;
																cur_aux->name = (char *) ((table_values_t *) cur_arg->value) -> tokenvalue;
																if (cur_arg->next != NULL) {
																	cur_aux->next = (arg_list_t *) malloc (sizeof(arg_list_t));
																}
																cur_aux = cur_aux->next;
																cur_arg = cur_arg->next;
															}
															entry->argList = func_arg_list;
														   }
| Static Type TK_IDENTIFICADOR '(' ')' {	$$ = $3;
											table_values_t *entry = ((table_values_t *) ($3->value));
											char *name = (char *) entry->tokenvalue;
											if (isInTable(name) == 1 && entry->identType != -1) quit(IKS_ERROR_DECLARED, "Identificador redeclarado.");
											else entry->identType = $2 + 6;
										}
;

EntryParams: Const Type TK_IDENTIFICADOR ',' EntryParams	{comp_dict_item_t *arg = (comp_dict_item_t *) malloc (sizeof(comp_dict_item_t));
															 table_values_t *arg_var = $3->value;
															 arg->key = $3->key;
															 table_values_t *aux = (table_values_t *) malloc (sizeof(table_values_t));
															 aux->tokenvalue = arg_var->tokenvalue;
															 aux->type = arg_var->type;
															 arg_var = aux;
															 arg->value = arg_var;	
															 arg_var->numline = -1;
															 arg_var -> isStatic = 0;
															 arg_var -> isConst = $1;
															 arg_var -> isVector = 0;
															 arg_var -> argList = NULL;
															 arg_var -> identType = $2;
															 arg -> next = $5;
															 remainderArgs = arg;
															 $$ = arg;															
															}


| Const Type TK_IDENTIFICADOR								{comp_dict_item_t *arg = (comp_dict_item_t *) malloc (sizeof(comp_dict_item_t));
															 table_values_t *arg_var = $3->value;
															 arg->key = $3->key;
														     table_values_t *aux = (table_values_t *) malloc (sizeof(table_values_t));
															 aux->tokenvalue = arg_var->tokenvalue;
															 aux->type = arg_var->type;
															 arg_var = aux;
															 arg->value = arg_var;
															 arg_var->numline = -1;
															 arg_var -> isStatic = 0;
															 arg_var -> isConst = $1;
															 arg_var -> isVector = 0;
															 arg_var -> argList = NULL;
															 arg_var -> identType = $2;
															 arg -> next = NULL;
															 remainderArgs = arg;
															 $$ = arg;														
															}
;

CommandBlock: '{' Scope Commands NoScope '}' {$$ = $3;}
| '{' Scope NoScope '}' {$$ = NULL;}
;

Scope : %empty {pushTable();}
;

NoScope : %empty {popTable();}
;

Commands: Command ';' Commands {if ($1 != NULL) { conectaNodo($1, $3); $$ = $1;} else { $$ = $3; }}
| Command	';' {$$ = $1;}
;


Command: VarDeclaration{$$ = $1;}	// Done
| FunctionCall {$$ = $1;}	// Done
| Attribution  {$$ = $1;}	// Done
| Input	{$$ = $1;} 	// Done
| Output  {$$ = $1;}	// Done
| ShiftExp {$$ = $1;}	// Done
| Return	{$$ = $1;}	// Done
| Break	{$$ = $1;}	// Done
| Continue	{$$ = $1;}	// Done
| If		{$$ = $1;}	// Done
| While		{$$ = $1;}	// Done
| For		{$$ = $1;}	
| ForEach	{$$ = $1;}
| Switch	{$$ = $1;}
| CommandBlock	{$$ = $1;}	// Done
| PipeExpr	{$$ = $1;}
| Case 		{$$ = $1;}
;

Case : TK_PR_CASE Literal ':' CommandBlock	{$$  = fazNodo(AST_CASE, NULL); conectaNodo($$, $2); conectaNodo($$, $4);}

If: TK_PR_IF '(' Expression ')' TK_PR_THEN CommandBlock	{$$ = fazNodo(AST_IF_ELSE, NULL); conectaNodo($$, $3); conectaNodo($$, $6);} 
| TK_PR_IF '(' Expression ')' TK_PR_THEN CommandBlock TK_PR_ELSE CommandBlock	{$$ = fazNodo(AST_IF_ELSE, NULL); conectaNodo($$, $3); conectaNodo($$, $6); comp_tree_t *aux = fazNodo(AST_ELSE, NULL); conectaNodo($$, aux); conectaNodo(aux, $8);} ;

While: TK_PR_WHILE '(' Expression ')' TK_PR_DO CommandBlock	{$$ = fazNodo(AST_WHILE_DO, NULL); conectaNodo($$, $3); conectaNodo($$, $6);
																															if (validaExpression($3) != TYPE_BOOL)
																																	quit(IKS_ERROR_TYPE_MISMATCH, "While expression should be bool");} 
| TK_PR_DO CommandBlock TK_PR_WHILE '(' Expression ')'		{$$ = fazNodo(AST_DO_WHILE, NULL); conectaNodo($$, $2); conectaNodo($$, $5);
																															if (validaExpression($5) != TYPE_BOOL)
																																	quit(IKS_ERROR_TYPE_MISMATCH, "While expression should be bool");} 
;

For: TK_PR_FOR Scope '(' ForList ':' Expression ':' ForList ')' '{' Commands NoScope '}'	{$$ = fazNodo(AST_FOR, NULL); conectaNodo($$, $4); conectaNodo($$, $6); conectaNodo($$, $8); conectaNodo($$, $11);
																																				if (validaExpression($6) != TYPE_BOOL)
																																					quit(IKS_ERROR_TYPE_MISMATCH, "For expression should be bool");} 
;

ForList: CommandFor ',' ForList		{if ($1 != NULL) { conectaNodo($1, $3); $$ = $1;} else { $$ = $3; }}
| CommandFor				{$$ = $1;}
;

CommandFor: VarDeclaration 	{$$ = $1;}
| FunctionCall 	{$$ = $1;}
| Attribution 	{$$ = $1;}
| ShiftExp 	{$$ = $1;}	
| Return 	{$$ = $1;}
| Break 	{$$ = $1;}
| Continue 	{$$ = $1;}
| If		{$$ = $1;}
| While		{$$ = $1;}
| For		{$$ = $1;}
| ForEach	{$$ = $1;}
| CommandBlock	{$$ = $1;}
| Switch	{$$ = $1;}
| PipeExpr 	{$$ = $1;}
;

ForEach: TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' ForEachList ')' CommandBlock	{$$ = fazNodo(AST_FOREACH, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $3)); conectaNodo($$, $5); conectaNodo($$, $7);}
;

ForEachList: Expression ',' ForEachList				{$$ = $1; conectaNodo($$, $3);}
| Expression							{$$ = $1;}
;

Switch: TK_PR_SWITCH '(' Expression ')' CommandBlock		{$$ = fazNodo(AST_SWITCH, NULL); conectaNodo($$, $3); conectaNodo($$, $5);}
;

Return: TK_PR_RETURN Expression		{$$ = fazNodo(AST_RETURN, NULL); conectaNodo($$, $2);} 
;
		
Break: TK_PR_BREAK		{$$ = fazNodo(AST_BREAK, NULL);}
;

Continue: TK_PR_CONTINUE		{$$ = fazNodo(AST_CONTINUE, NULL);}
;

ShiftExp: TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT		{$$ = fazNodo(AST_SHIFT_RIGHT, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, fazNodo(AST_LITERAL, $3));}
| TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT			{$$ = fazNodo(AST_SHIFT_LEFT, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, fazNodo(AST_LITERAL, $3));} 
;

Input: TK_PR_INPUT Expression		{$$ = fazNodo(AST_INPUT, NULL); conectaNodo($$, $2);}
;

Output: TK_PR_OUTPUT OutputList		{$$ = fazNodo(AST_OUTPUT, NULL); conectaNodo($$, $2);}
;

OutputList: Expression ',' OutputList	{$$ = $1; conectaNodo($1, $3);}
| Expression				{$$ = $1;}
;

Attribution: TK_IDENTIFICADOR '=' Expression		{$$ = fazNodo(AST_ATRIBUICAO, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, $3);
														comp_dict_item_t *aux = (getFromTable((char *) ((table_values_t *) ($1->value)) ->tokenvalue, 0));
														if (aux == NULL) quit(IKS_ERROR_UNDECLARED, "Identificador de variável não declarado.");
														table_values_t *entryvalues = (table_values_t *) (aux->value);
														if (entryvalues -> isVector >= 1) quit(IKS_ERROR_VECTOR, "Identificador de vetor não foi indexado.");
														if (entryvalues -> identType >= TYPE_FUN_INT) quit(IKS_ERROR_FUNCTION, "Identificador deve ser utilizado como função.");
														if (entryvalues->identType != TYPE_INT && entryvalues->identType != TYPE_FLOAT) { if (entryvalues->identType != validaExpression($3)) quit(IKS_ERROR_TYPE_MISMATCH, "Attribution type mismatch"); }
														else if ((validaExpression($3) != TYPE_INT) && (validaExpression($3) != TYPE_FLOAT)) quit(IKS_ERROR_TYPE_MISMATCH, "Attribution type mismatch");
														table_values_t *this_value = (table_values_t *) ($1->value);
														this_value->reg_offset = entryvalues->reg_offset;
														this_value->isGlobal = entryvalues->isGlobal;
													}
| TK_IDENTIFICADOR '[' Expression ']' '=' Expression	{$$ = fazNodo(AST_ATRIBUICAO, NULL); comp_tree_t *vet = fazNodo(AST_VETOR_INDEXADO, NULL); conectaNodo($$, vet); conectaNodo(vet, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo(vet, $3); conectaNodo($$, $6);
																												table_values_t *entryvalues = (table_values_t *) ((getFromTable((char *) ((table_values_t *) ($1->value)) ->tokenvalue, 0))->value);
																												if (entryvalues -> identType >= TYPE_FUN_INT) quit(IKS_ERROR_FUNCTION, "Identificador deve ser utilizado como função.");
																												if (entryvalues -> isVector < 1) quit(IKS_ERROR_VARIABLE, "Identificador de variável utilizado indevidamente");																											
																												if (entryvalues->identType != TYPE_INT && entryvalues->identType != TYPE_FLOAT) { if (entryvalues->identType != validaExpression($6)) quit(IKS_ERROR_TYPE_MISMATCH, "Attribution type mismatch"); }
																												else if ((validaExpression($6) != TYPE_INT) && (validaExpression($6) != TYPE_FLOAT)) quit(IKS_ERROR_TYPE_MISMATCH, "Attribution type mismatch");
																												if ((validaExpression($3) != TYPE_INT) && (validaExpression($3) != TYPE_FLOAT)) quit(IKS_ERROR_TYPE_MISMATCH, "Indexing type mismatch");
																												table_values_t *this_value = (table_values_t *) ($1->value);
																												this_value->reg_offset = entryvalues->reg_offset;
																												this_value->isGlobal = entryvalues->isGlobal;
   																											if (entryvalues->identType == TYPE_INT || entryvalues->identType == TYPE_FLOAT) this_value->typeSize = 4;
																											}
																												
| TK_IDENTIFICADOR '.' TK_IDENTIFICADOR '=' Expression	{$$ = fazNodo(AST_ATRIBUICAO, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $3)); conectaNodo($$, $5);} 
;

Expression: AritExpr			{$$ = $1; validaExpression($1);} 
| LogExpr				{$$ = $1; validaExpression($1);} 
| PipeExpr				{$$ = $1; validaExpression($1);}
| NewLogExpr				{$$ = $1; validaExpression($1);}
;

AritExpr: AritExpr '+' AritExpr		{$$ = fazNodo(AST_ARIM_SOMA, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr '-' AritExpr			{$$ = fazNodo(AST_ARIM_SUBTRACAO, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr '*' AritExpr			{$$ = fazNodo(AST_ARIM_MULTIPLICACAO, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr '/' AritExpr			{$$ = fazNodo(AST_ARIM_DIVISAO, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| '+' AritExpr				{$$ = $2;}
| '-' AritExpr				{$$ = fazNodo(AST_ARIM_INVERSAO, NULL); conectaNodo($$, $2);}
| '(' AritExpr ')'			{$$ = $2;}
| Operands				{$$ = $1;}
;

LogExpr:  AritExpr TK_OC_LE AritExpr 	{$$ = fazNodo(AST_LOGICO_COMP_LE, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr TK_OC_GE AritExpr		{$$ = fazNodo(AST_LOGICO_COMP_GE, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr TK_OC_EQ AritExpr		{$$ = fazNodo(AST_LOGICO_COMP_IGUAL, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr TK_OC_NE AritExpr		{$$ = fazNodo(AST_LOGICO_COMP_DIF, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr '>' AritExpr			{$$ = fazNodo(AST_LOGICO_COMP_G, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| AritExpr '<' AritExpr			{$$ = fazNodo(AST_LOGICO_COMP_L, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| '(' LogExpr ')'			{$$ = $2;}
;

NewLogExpr: LogExpr TK_OC_AND LogExpr		{$$ = fazNodo(AST_LOGICO_E, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| LogExpr TK_OC_OR LogExpr			{$$ = fazNodo(AST_LOGICO_OU, NULL); conectaNodo($$, $1); conectaNodo($$, $3);}
| '(' NewLogExpr ')'			{$$ = $2;}
;

PipeExpr:  FunctionCall PipeTokens PipeRecursion 	{$$ = $2; conectaNodo($$, $1); conectaNodo($$, $3);}
;

PipeRecursion: FunctionCall PipeTokens PipeRecursion	{$$ = $2; conectaNodo($$, $1); conectaNodo($$, $3);}
| FunctionCall						{$$ = $1;}
;

PipeTokens: TK_OC_PIP			{$$ = fazNodo(AST_PIPE1, NULL);}
| TK_OC_OOR				{$$ = fazNodo(AST_PIPE2, NULL);}
;

Operands: TK_IDENTIFICADOR ArraySizeExp  {if ($2 == NULL) { $$ = fazNodo(AST_IDENTIFICADOR, $1);} else {$$ = fazNodo(AST_VETOR_INDEXADO, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, $2);}}
| Literal				 {$$ = $1;}
| FunctionCall	 {$$ = $1;}
;

FunctionCall: TK_IDENTIFICADOR '(' CallParams ')'		{$$ = fazNodo(AST_CHAMADA_DE_FUNCAO, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1)); conectaNodo($$, $3);
														table_values_t *valores = (table_values_t *) $1->value;
														comp_dict_item_t *value_var = getFromTable((char *) valores->tokenvalue, 0);
														valores->argList = ((table_values_t *) value_var->value)->argList;
														if (value_var == NULL) quit(IKS_ERROR_UNDECLARED, "Identificador de função não declarado.");
														else {
															valores = (table_values_t *) value_var->value;
															if (valores->identType < TYPE_FUN_INT) quit (IKS_ERROR_VARIABLE, "Identificador de variável utilizado em função.");
															if (valores->argList == NULL) quit (IKS_ERROR_EXCESS_ARGS, "Função não precisa de tantos argumentos");
															comp_tree_t *aux = $3;
															arg_list_t *lista_args = valores->argList;	

															while(1) {
																if (aux == NULL) {
																	if (lista_args == NULL)
																		break;
																	else
																		quit(IKS_ERROR_MISSING_ARGS, "Função precisa de mais argumentos.");
																}
																if (lista_args == NULL) 
																	quit(IKS_ERROR_EXCESS_ARGS, "Função não precisa de tantos argumentos");
																int node_type = ((comp_tree_value_t *) aux->value)->type;
																table_values_t *table_val = NULL;
																comp_dict_item_t *item_aux = NULL;
																char *name = NULL;
																switch(node_type) {
																	case AST_LITERAL: table_val = (table_values_t *) ((comp_dict_item_t *) ((comp_tree_value_t *) aux->value)->tableEntry)->value;
																					  if (table_val->type == POA_LIT_INT || table_val->type == POA_LIT_FLOAT) {
																						if (lista_args->type != TYPE_INT && lista_args->type != TYPE_FLOAT)
																							quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado.");
																					  }
																					  else if ((table_val->type == POA_LIT_CHAR || table_val->type == POA_LIT_STRING || table_val->type == POA_LIT_BOOL) && (lista_args->type != table_val ->type))
																							quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																					  aux = aux->last;
																					  break;
																	case AST_ARIM_SOMA:
																	case AST_ARIM_SUBTRACAO:
																	case AST_ARIM_MULTIPLICACAO:
																	case AST_ARIM_DIVISAO:	if (aux->last != aux->first->next) 	
																								aux = aux->last;
																							else 
																								aux = NULL; 
																							if (lista_args->type != TYPE_INT && lista_args->type != TYPE_FLOAT)
																									quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado.");
																							break;
																	case AST_ARIM_INVERSAO: if (aux->last != aux->first) 	
																								aux = aux->last;
																							else 
																								aux = NULL; 
																							if (lista_args->type != TYPE_INT && lista_args->type != TYPE_FLOAT)
																									quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado.");
																							break;	
																	case AST_LOGICO_COMP_LE:
																	case AST_LOGICO_COMP_GE:
																	case AST_LOGICO_COMP_IGUAL:
																	case AST_LOGICO_COMP_DIF:
																	case AST_LOGICO_COMP_G:
																	case AST_LOGICO_COMP_L:
																	case AST_LOGICO_E:
																	case AST_LOGICO_OU:	if (aux->last != aux->first->next) 	
																							aux = aux->last;																						
																						else 
																							aux = NULL; 
																						if (lista_args->type != TYPE_BOOL)
																									quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado.");
																						break;
																	case AST_IDENTIFICADOR: table_val = (table_values_t *) ((comp_dict_item_t *) ((comp_tree_value_t *) aux->value)->tableEntry)->value;
																							name = (char *) table_val->tokenvalue;
																							item_aux = getFromTable(name, 0);
																							if (item_aux == NULL) quit(IKS_ERROR_UNDECLARED, "Identificador não declarado.");
																							table_val = (table_values_t *) item_aux->value;
																							if (table_val -> isVector >= 1) quit(IKS_ERROR_VECTOR, "Identificador de vetor não foi indexado.");
																							if (table_val -> identType >= TYPE_FUN_INT) quit(IKS_ERROR_FUNCTION, "Identificador deve ser utilizado como função.");
																							if (lista_args->type != TYPE_INT && lista_args->type != TYPE_FLOAT) { if (lista_args->type != table_val->identType) quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado."); }
																							else if (table_val->identType != TYPE_INT && table_val->identType != TYPE_FLOAT) quit(IKS_ERROR_WRONG_TYPE_ARGS, "Parâmetro de tipo errado.");
																	default:		aux = aux->last;
																					break;
																}
																lista_args = lista_args->next;
															}
														}	} 
| TK_IDENTIFICADOR '(' ')'					{	$$ = fazNodo(AST_CHAMADA_DE_FUNCAO, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $1));
											table_values_t *valores = (table_values_t *) $1->value;
											comp_dict_item_t *value_var = getFromTable((char *) valores->tokenvalue, 0);
											if (value_var == NULL) quit(IKS_ERROR_UNDECLARED, "Identificador de função não declarado.");
											else {
												valores = (table_values_t *) value_var->value;
												if (valores->identType < TYPE_FUN_INT) quit (IKS_ERROR_VARIABLE, "Identificador de variável utilizado em função.");
												if (valores->argList != NULL) quit (IKS_ERROR_MISSING_ARGS, "Função precisa de mais argumentos");
											}	} 
;

CallParams: Expression ',' CallParams			{$$ = $1; conectaNodo($$, $3);}
| '.' ',' CallParams				{$$ = fazNodo(AST_DOT, NULL); conectaNodo($$, $3);}
| '.'						{$$ = fazNodo(AST_DOT, NULL);}
| Expression					{$$ = $1;}
;

VarDeclaration: TK_PR_STATIC VarDeclaration1		{$$ = $2;}
| VarDeclaration1				{$$ = $1;}
;

VarDeclaration1: TK_PR_CONST VarDeclaration2 	{$$ = $2;}
| VarDeclaration2	{$$ = $1;}
;

VarDeclaration2: TK_IDENTIFICADOR TK_IDENTIFICADOR	{$$ = NULL;} //User Type TODO
| PrimType TK_IDENTIFICADOR RightAttr	{table_values_t *entry = ((table_values_t *) ($2->value)); char *name = (char *) entry->tokenvalue; if (isInTable(name) == 1 && entry->identType != -1) quit(IKS_ERROR_DECLARED, "Identificador redeclarado."); else {entry->identType = $1; entry->isVector = 0;} //TODO: ARRUMAR CONST E STATIC
											if ($3 == NULL) $$ = NULL; else { $$ = fazNodo(AST_DECLARATION, NULL); conectaNodo($$, fazNodo(AST_IDENTIFICADOR, $2)); conectaNodo($$, $3);
																				table_values_t *valores = (table_values_t *) ((comp_dict_item_t *) ((comp_tree_value_t *) $3->value)->tableEntry)->value;
																				if (valores->type != 6){
																						if ((valores->type == POA_LIT_INT || valores->type == POA_LIT_FLOAT) && ($1 != TYPE_INT && $1 != TYPE_FLOAT))
																							quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																						if ((valores->type == POA_LIT_CHAR || valores->type == POA_LIT_STRING || valores->type == POA_LIT_BOOL) && (valores->type != $1))
																							quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																				 }
																				 else {
																						comp_dict_item_t *value_var = getFromTable((char *) valores->tokenvalue, 0);
																						if (value_var == NULL)
																							quit(IKS_ERROR_UNDECLARED, "Variável não declarada.");
																						switch(((table_values_t *) value_var->value)->identType) {
																							
																							case TYPE_INT:
																							case TYPE_FLOAT: if ($1 != TYPE_INT && $1 != TYPE_FLOAT)
																												quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																										   break;
																							case TYPE_CHAR:
																							case TYPE_STRING:
																							case TYPE_BOOL: if ($1 != ((table_values_t *) value_var->value)->identType)
																												quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																											break;
																							case TYPE_FUN_INT:
																							case TYPE_FUN_FLOAT:
																							case TYPE_FUN_CHAR:
																							case TYPE_FUN_STRING:
																							case TYPE_FUN_BOOL:	quit(IKS_ERROR_FUNCTION, "Identificador de função utilizado indevidamente."); 
																												break;
																							default: quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
																											break;
																						}
																						if (((table_values_t *) value_var->value)->isVector > 0)
																							quit(IKS_ERROR_VECTOR, "Identificador de vetor não foi indexado");
																						table_values_t *node_value = (table_values_t *) (((comp_tree_value_t *) ($3->value))->tableEntry)->value;
																						table_values_t *search_value = ((table_values_t *) value_var->value);
																						node_value->reg_offset = search_value->reg_offset;
																						node_value->isGlobal = search_value->isGlobal;
																							
																				 }
																				 
																				 }
																				  
																				  table_values_t *this_value = (table_values_t *) ($2->value);
																			    this_value->reg_offset = table->register_offset;

																			    if ($1 == TYPE_INT || $1 == TYPE_FLOAT) (table->register_offset) += 4;
																					else (table->register_offset)++;
																				  this_value->isGlobal = 0;
																				  }
									
;

RightAttr: TK_OC_LE TK_IDENTIFICADOR	{ $$ = fazNodo(AST_IDENTIFICADOR, $2); }
| TK_OC_LE Literal			{ $$ = $2; }
| %empty 				{ $$ = NULL; }
;

Literal: TK_LIT_INT	{$$ = fazNodo(AST_LITERAL, $1);}
| TK_LIT_FLOAT		{$$ = fazNodo(AST_LITERAL, $1);}
| TK_LIT_FALSE		{$$ = fazNodo(AST_LITERAL, $1);}
| TK_LIT_TRUE		{$$ = fazNodo(AST_LITERAL, $1);}
| TK_LIT_CHAR		{$$ = fazNodo(AST_LITERAL, $1);}
| TK_LIT_STRING		{$$ = fazNodo(AST_LITERAL, $1);}
;

Const: TK_PR_CONST	{$$ = 1;}
| %empty			{$$ = 0;}
;

TypeDeclaration: TK_PR_CLASS TK_IDENTIFICADOR '[' FieldList ']' ';'
;

FieldList: Encapsulation PrimType TK_IDENTIFICADOR ':' FieldList
| Encapsulation PrimType TK_IDENTIFICADOR
;

Encapsulation: TK_PR_PRIVATE
| TK_PR_PUBLIC
| TK_PR_PROTECTED
;

GVarDeclaration: Static Type TK_IDENTIFICADOR ArraySize ';' {	table_values_t *entry = ((table_values_t *) ($3->value)); char *name = (char *) entry->tokenvalue; if (isInTable(name) == 1 && entry->identType != -1) quit(IKS_ERROR_DECLARED, "Identificador redeclarado"); else { entry->identType = $2; entry-> isGlobal = 1; entry->reg_offset = table->register_offset;
															    if ($2 == TYPE_FLOAT || $2 == TYPE_INT) {if ($4 > 0) table->register_offset += $4 * 4; else table->register_offset += 4;}
																	else {if ($4 > 0) table->register_offset += $4; else table->register_offset++;}
															    entry->isStatic = $1; entry->isVector = $4; entry->isConst = 0;} }
;

Static: TK_PR_STATIC		{$$ = 1;}
| %empty					{$$ = 0;}
;

ArraySize: '[' TK_LIT_INT ']'	{ table_values_t *entry = ((table_values_t *) ($2->value)); $$ = *((int *) entry->tokenvalue); }
| %empty	{$$ = 0;}
;

ArraySizeExp: '[' Expression ']'  	{$$ = $2;}
| %empty				{$$ = NULL;}
;

Type: PrimType		{$$ = $1;}
| TK_IDENTIFICADOR	{$$ = TYPE_USER;} //TODO
;

PrimType: TK_PR_FLOAT	{$$ = TYPE_FLOAT;}
| TK_PR_INT				{$$ = TYPE_INT;}
| TK_PR_CHAR			{$$ = TYPE_CHAR;}
| TK_PR_STRING			{$$ = TYPE_STRING;}
| TK_PR_BOOL			{$$ = TYPE_BOOL;}
;

%%

char *createLabel(char *fname) {
	char *name = (char *) malloc (sizeof(char) * 100);
	strcpy(name, "L");
	if (fname == NULL) {
		char str_number[12];
		sprintf(str_number, "%d", currentLabel);
		currentLabel++;
		strcat(name, str_number);
	}
	else {
		strcat(name, fname);
	}
	return name;
}

int createRegister() {
	
	int a = currentRegister;
	currentRegister++;
	return a;
}

operation_list_t *createOperation(int opCode, char *marker) {
	operation_list_t *cur_operation_l = (operation_list_t *) malloc (sizeof(operation_t));
	operation_t *cur_operation = (operation_t *) malloc (sizeof(operation_t));
	cur_operation->opcode = opCode;
	cur_operation->marker = marker;
	
	switch(opCode) {
			case OP_nop: cur_operation->numinput = 0;
						 cur_operation->numoutput = 0;
						 break;
			case OP_add:
			case OP_sub:
			case OP_mult:
			case OP_div:
			case OP_addI:
			case OP_subI:
			case OP_rsubI:
			case OP_multI:
			case OP_divI:
			case OP_rdivI:
			case OP_lshift:
			case OP_lshiftI:
			case OP_rshift:
			case OP_rshiftI:
			case OP_and:
			case OP_andI:
			case OP_or:
			case OP_orI:
			case OP_loadAI:
			case OP_loadA0:
			case OP_xor:
			case OP_cmp_LT:
			case OP_cmp_LE:
			case OP_cmp_EQ:
			case OP_cmp_GE:
			case OP_cmp_GT:
			case OP_cmp_NE:
			case OP_cloadAI:
			case OP_cloadA0:
			case OP_xorI:	cur_operation->numinput = 2;
							cur_operation->numoutput = 1;
							break;
			case OP_cload:
			case OP_store:
			case OP_cstore:
			case OP_loadI:
			case OP_i2i:
			case OP_c2c:
			case OP_c2i:
			case OP_i2c:
			case OP_load:	cur_operation->numinput = 1;
							cur_operation->numoutput = 1;
							break;
			case OP_jumpI:
			case OP_jump:	cur_operation->numinput = 0;
							cur_operation->numoutput = 1;
							break;
			case OP_cstoreAI:
			case OP_cstoreA0:
			case OP_storeAI:
			case OP_cbr:
			case OP_storeA0:cur_operation->numinput = 1;
							cur_operation->numoutput = 2;
							break;
	}
	if (cur_operation->numinput) {
		cur_operation->input = (int *) malloc (sizeof(int) * cur_operation->numinput);
	}
	else {
		cur_operation->input = NULL;
	}
	if (cur_operation->numoutput) {
		cur_operation->output = (int *) malloc (sizeof(int) * cur_operation->numoutput);
	}
	else {
		cur_operation->output = NULL;
	}
	
	cur_operation_l->operation = cur_operation;
	return cur_operation_l;
}

void printOperation (operation_list_t *op_l) {
	char i1[2];
	char i2[2];
	char o1[2];
	char o2[2];
	char a[3];

	char opcode[10];

	operation_t *op = op_l->operation;
	
	switch(op->opcode) {
			case OP_nop: 		strcpy(opcode, "nop"); strcpy(i1, ""); strcpy(i2, ""); strcpy(o1, ""); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_add: 		strcpy(opcode, "add"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_sub: 		strcpy(opcode, "sub"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_mult:		strcpy(opcode, "mult"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_div:		strcpy(opcode, "div"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_addI:		strcpy(opcode, "addI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_subI:		strcpy(opcode, "subI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_rsubI:		strcpy(opcode, "rsubI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_multI:		strcpy(opcode, "multI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_divI:		strcpy(opcode, "divI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_rdivI:		strcpy(opcode, "rdivI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_lshift:		strcpy(opcode, "lshift"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_lshiftI:	strcpy(opcode, "lshiftI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_rshift:		strcpy(opcode, "rshift"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_rshiftI:	strcpy(opcode, "rshiftI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_and:		strcpy(opcode, "and"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_andI:		strcpy(opcode, "andI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_or:			strcpy(opcode, "or"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_orI:		strcpy(opcode, "orI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_loadAI:		strcpy(opcode, "loadAI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_loadA0:		strcpy(opcode, "loadAO"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_xor:		strcpy(opcode, "xor"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cmp_LT:		strcpy(opcode, "cmp_LT"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cmp_LE:		strcpy(opcode, "cmp_LE"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cmp_EQ:		strcpy(opcode, "cmp_EQ"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cmp_GE:		strcpy(opcode, "cmp_GE"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cmp_GT:		strcpy(opcode, "cmp_GT"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cmp_NE:		strcpy(opcode, "cmp_NE"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_cloadAI:	strcpy(opcode, "cloadAI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cloadA0:	strcpy(opcode, "cloadAO"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_xorI:		strcpy(opcode, "xorI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cload:		strcpy(opcode, "cload"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_store:		strcpy(opcode, "store"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cstore:		strcpy(opcode, "cstore"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_loadI:		strcpy(opcode, "loadI"); strcpy(i1, ""); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_i2i:		strcpy(opcode, "i2i"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_c2c:		strcpy(opcode, "c2c"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_c2i:		strcpy(opcode, "c2i"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_i2c:		strcpy(opcode, "i2c"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_jumpI:		strcpy(opcode, "jumpI"); strcpy(i1, ""); strcpy(i2, ""); strcpy(o1, "l"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_jump:		strcpy(opcode, "jump"); strcpy(i1, ""); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "->"); break;
			case OP_load:		strcpy(opcode, "load"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cstoreAI:	strcpy(opcode, "cstoreAI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cstoreA0:	strcpy(opcode, "cstoreAO"); strcpy(i1, "r"); strcpy(i2, "r"); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_storeAI:	strcpy(opcode, "storeAI"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, ""); strcpy(a, "=>"); break;
			case OP_cbr:		strcpy(opcode, "cbr"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "l"); strcpy(o2, "l"); strcpy(a, "->"); break;
			case OP_storeA0:	strcpy(opcode, "storeAO"); strcpy(i1, "r"); strcpy(i2, ""); strcpy(o1, "r"); strcpy(o2, "r"); strcpy(a, "=>"); break;
	}	

	if (op->marker != NULL) {
		printf("%s: ", op->marker);
		fprintf(fp, "%s: ", op->marker);
	}

	printf("%s ", opcode);
	fprintf(fp, "%s ", opcode);

	if (op->numinput >= 1){
		if (strcmp(i1, "r") == 0 && (op->input)[0] == -1) {
			printf("rarp");
			fprintf(fp, "rarp");	
		}
		else if (strcmp(i1, "r") == 0 && (op->input)[0] == -2) {
			printf("rbss");
			fprintf(fp, "rbss");
		}
		else if (strcmp(i1, "r") == 0 && (op->input)[0] == -3) {
			printf("rsp");
			fprintf(fp, "rsp");
		}
		else if (strcmp(i1, "r") == 0 && (op->input)[0] == -4) {
			printf("rpc");
			fprintf(fp, "rpc");
		}
		else {
			printf("%s%d", i1, (op->input)[0]);
			fprintf(fp, "%s%d", i1, (op->input)[0]);
		}
	}

	if (op->numinput == 2) {
		if (strcmp(i2, "r") == 0 && (op->input)[1] == -1) {
			printf("rarp");
			fprintf(fp, "rarp");	
		}
		else if (strcmp(i2, "r") == 0 && (op->input)[1] == -2) {
			printf("rbss");
			fprintf(fp, "rbss");	
		}
		else if (strcmp(i2, "r") == 0 && (op->input)[1] == -3) {
			printf("rsp");
			fprintf(fp, "rsp");	
		}
		else if (strcmp(i2, "r") == 0 && (op->input)[1] == -4) {
			printf("rpc");
			fprintf(fp, "rpc");	
		}
		else {
			printf(", %s%d ", i2, (op->input)[1]);
			fprintf(fp, ", %s%d ", i2, (op->input)[1]);
		}
	}
	else { printf(" "); fprintf(fp, " ");}


	if (op->numoutput >= 1) {
		printf("%s ", a);
		fprintf(fp, "%s ", a);
		if (strcmp(o1, "r") == 0 && (op->output)[0] == -1) {
			printf("rarp");
			fprintf(fp, "rarp");	
		}
		else if (strcmp(o1, "r") == 0 && (op->output)[0] == -2) {
			printf("rbss");
			fprintf(fp, "rbss");	
		}
		else if (strcmp(o1, "r") == 0 && (op->output)[0] == -3) {
			printf("rsp");
			fprintf(fp, "rsp");	
		}
		else if (strcmp(o1, "r") == 0 && (op->output)[0] == -4) {
			printf("rpc");
			fprintf(fp, "rpc");	
		}
		else { 
			if ((op->output)[0] == -45){
				printf("%s", (op->alterOutput)[0]);
				fprintf(fp, "%s", (op->alterOutput)[0]);
			}
			else {
				printf("%s%d", o1, (op->output)[0]);
				fprintf(fp, "%s%d", o1, (op->output)[0]);
			}
		}
	}
	if (op->numoutput == 2) {
		if (strcmp(o2, "r") == 0 && (op->output)[1] == -1) {
			printf("rarp");
			fprintf(fp, "rarp");	
		}
		else if (strcmp(o2, "r") == 0 && (op->output)[1] == -2) {
			printf("rbss");
			fprintf(fp, "rbss");	
		}
		else if (strcmp(o2, "r") == 0 && (op->output)[1] == -3) {
			printf("rsp");
			fprintf(fp, "rsp");	
		}
		else if (strcmp(o2, "r") == 0 && (op->output)[1] == -4) {
			printf("rpc");
			fprintf(fp, "rpc");	
		}
		else if ((op->output)[1] == -45) {
			printf(", %s", (op->alterOutput)[1]);
			fprintf(fp, ", %s", (op->alterOutput)[1]);
		}
		else {
			printf(", %s%d", o2, (op->output)[1]);
			fprintf(fp, ", %s%d", o2, (op->output)[1]);
		}
	}

	printf("\n");
	fprintf(fp, "\n");


	if (op_l ->next != NULL)
		printOperation(op_l->next);

}

operation_list_t *iniciaCodigoFromTree(comp_tree_t *nodo) {
	operation_list_t *code_list;
	operation_list_t *aux_code;
	operation_t *operation;

	char *lc;

	lc = createLabel("main");

	code_list = createOperation(OP_loadI, NULL);
	operation = code_list->operation;
	operation->input[0] = 0;
	operation->output[0] = -1;

	code_list->next = createOperation(OP_loadI, NULL);
	aux_code = code_list->next;
	operation = aux_code->operation;
	operation->input[0] = 0;
	operation->output[0] = -2;

	aux_code->next = createOperation(OP_loadI, NULL);
	aux_code = aux_code->next;
	operation = aux_code->operation;
	operation->input[0] = 0;
	operation->output[0] = -3;

	aux_code->next = createOperation(OP_jumpI, NULL);
	aux_code = aux_code->next;
	operation = aux_code->operation;
	operation->output[0] = -45;
	operation->alterOutput[0] = lc;

	aux_code->next = criaCodigoFromTree(nodo, 0);

	return code_list;
}

operation_list_t *criaCodigoFromTree(comp_tree_t *nodo, int isMain) {
	if (nodo == NULL)
		return NULL;
		
	operation_list_t *code_list;
	operation_list_t *aux_code;
	operation_t *operation;
	int *bandaid;
	arg_list_t *params;
	comp_tree_t *aux_nodo;
	int ra, rb, rc;
	char *la, *lb, *lc;
	comp_tree_value_t *valor_nodo = (comp_tree_value_t *) nodo->value;
	table_values_t *entry_values = NULL;
	int auxcont;

	switch(valor_nodo->type) {
			//TODO: PARAMETRAGEM
			case AST_FUNCAO:		entry_values = (table_values_t *) (valor_nodo->tableEntry)->value;

									la = createLabel((char *) entry_values->tokenvalue);
									code_list = createOperation(OP_i2i, la);
								
									if (strcmp(la, "Lmain") == 0) isMain = 1;
									else isMain = 0;

									operation = code_list->operation;
									operation->input[0] = -3;
									operation->output[0] = -1;

									code_list->next = createOperation(OP_addI, NULL);
									aux_code = code_list->next;
									operation = aux_code->operation;
									operation->input[0] = -3;
									operation->input[1] = entry_values->regSizeFun;
									if (isMain == 0) operation->input[1] += 12;
									operation->output[0] = -3;

									aux_code->next = criaCodigoFromTree(nodo->first, isMain);
				
									while (aux_code->next != NULL) aux_code = aux_code->next;

									if (nodo->first != nodo->last)
										aux_code->next = criaCodigoFromTree(nodo->last, 0);

									break;

			case AST_IDENTIFICADOR:	entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->value))->tableEntry)->value;
									code_list = createOperation(OP_loadAI, NULL);
									operation = code_list->operation;
									if (entry_values->isGlobal)	(operation->input)[0] = -2;
									else (operation->input)[0] = -1;
									(operation->input)[1] = entry_values->reg_offset;
									if (isMain == 0) operation->input[1] += 12;
									(operation->output)[0] = createRegister();
									break;


			case AST_CHAMADA_DE_FUNCAO: 
									ra = createRegister();

									entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;
									la = createLabel((char *) entry_values->tokenvalue);

									code_list = createOperation(OP_addI, NULL);
									operation = code_list->operation;
									operation->input[0] = -4;
									operation->input[1] = 5;
									bandaid = &(operation->input[1]);
									operation->output[0] = createRegister();

									code_list->next = createOperation(OP_storeAI, NULL);
									aux_code = code_list->next;
									operation = aux_code->operation;
									operation->input[0] = currentRegister-1;
									operation->output[0] = -3;
									operation->output[1] = 0;

									aux_code->next = createOperation(OP_storeAI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->input[0] = -3;
									operation->output[0] = -3;
									operation->output[1] = 4;

									aux_code->next = createOperation(OP_storeAI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->input[0] = -1;
									operation->output[0] = -3;
									operation->output[1] = 8;

									auxcont = 12;

									
									//TRATAR PARÂMETROS
									params = entry_values->argList;
									aux_nodo = nodo->first->next;
									while (params != NULL) {
											rb = currentRegister;
											aux_code->next = criaCodigoFromTree(aux_nodo, isMain);
											while (aux_code->next != NULL) { aux_code = aux_code->next; *bandaid +=1; }
											aux_code->next = createOperation(OP_storeAI, NULL);
											aux_code = aux_code->next;
											operation = aux_code->operation;
											operation->input[0] = rb;
											operation->output[0] = -3;
											operation->output[1] = auxcont;
											auxcont += 1;
											*bandaid += 1;
											if (params->type == TYPE_INT || params->type == TYPE_FLOAT)
													auxcont += 3;
											params = params->next;
											aux_nodo = aux_nodo ->last;	
									}

									aux_code->next = createOperation(OP_jumpI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->output[0] = -45;
									operation->alterOutput[0] = createLabel((char *) entry_values -> tokenvalue);

									aux_code->next = createOperation(OP_loadAI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->input[0] = -3;
									operation->input[1] = 0;
									operation->output[0] = ra;


									break;

			case AST_VETOR_INDEXADO: ra = createRegister();
						 rb = createRegister();
						 rc = currentRegister;
									code_list = criaCodigoFromTree(nodo->first->next, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;

									aux_code->next = createOperation(OP_multI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->input[0] = rc;
									if (entry_values->typeSize == 4) 					
										operation->input[1] = 4;
									else
										operation->input[1] = 1;
									operation->output[0] = rb;

									aux_code->next = createOperation(OP_addI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									operation->input[0] = rb;
									operation->input[1] = entry_values->reg_offset;
									if (isMain == 0) operation->input[1] += 12;
									operation->output[0] = rb;
									while (aux_code->next != NULL) aux_code = aux_code->next;
	
									aux_code->next = createOperation(OP_loadA0, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									if (entry_values->isGlobal)	(operation->input)[0] = -2;
									else (operation->input)[0] = -1;
									(operation->input)[1] = rb;
									(operation->output)[0] = ra;
									break;

			case AST_LITERAL:		entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->value))->tableEntry)->value;
									code_list = createOperation(OP_loadI, NULL);
									operation = code_list->operation;
									(operation->input)[0] = *((int *) entry_values->tokenvalue);
									(operation->output)[0] = createRegister();
									break;
			case AST_ARIM_INVERSAO:	rc = createRegister();
									ra = currentRegister;
					
									code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									rb = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_rsubI, NULL);
									operation = aux_code->next->operation;
									(operation->input)[0] = ra;
									(operation->input)[1] = 0;
									(operation->output)[0] = rc;
									break;
			case AST_SHIFT_RIGHT:
			case AST_SHIFT_LEFT:	rc = createRegister();
									ra = currentRegister;
					
									code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									rb = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);

									while (aux_code->next != NULL) aux_code = aux_code->next;

									if (valor_nodo->type == AST_SHIFT_RIGHT)	aux_code->next = createOperation(OP_rshift, NULL);
									else aux_code->next = createOperation(OP_lshift, NULL);
									operation = aux_code->next->operation;
									(operation->input)[0] = ra;
									(operation->input)[1] = rb;
									(operation->output)[0] = rc;

									if (((comp_tree_value_t *) (nodo->first)->value)->type != AST_VETOR_INDEXADO) {
											entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;
									}
									else
											entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->first->value))->tableEntry)->value;
									aux_code = aux_code->next;
									aux_code->next = createOperation(OP_storeAI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									if (entry_values->isGlobal)	(operation->output)[0] = -2;
										else (operation->output)[0] = -1;
									(operation->output)[1] = entry_values->reg_offset;
									if (isMain == 0) operation->output[1] += 12;
									(operation->input)[0] = rc;
					
									if (nodo->last != nodo->first && nodo->last != nodo->first->next)						
										aux_code->next = criaCodigoFromTree(nodo->last, isMain);
									break;		
			case AST_LOGICO_E:
			case AST_LOGICO_OU:
			case AST_LOGICO_COMP_DIF:
			case AST_LOGICO_COMP_IGUAL:
			case AST_LOGICO_COMP_LE:
			case AST_LOGICO_COMP_GE:
			case AST_LOGICO_COMP_L:
			case AST_LOGICO_COMP_G:
			case AST_ARIM_MULTIPLICACAO:
			case AST_ARIM_DIVISAO:
			case AST_ARIM_SUBTRACAO:
			case AST_ARIM_SOMA:		rc = createRegister();
									ra = currentRegister;
					
									code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									rb = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);

									while (aux_code->next != NULL) aux_code = aux_code->next;
									if (valor_nodo->type == AST_ARIM_SOMA)	aux_code->next = createOperation(OP_add, NULL);
									else if (valor_nodo->type == AST_ARIM_SUBTRACAO) aux_code->next = createOperation(OP_sub, NULL);
									else if (valor_nodo->type == AST_ARIM_MULTIPLICACAO)	aux_code->next = createOperation(OP_mult, NULL);
									else if (valor_nodo->type == AST_ARIM_DIVISAO)	aux_code->next = createOperation(OP_div, NULL);
									else if (valor_nodo->type == AST_LOGICO_E)	aux_code->next = createOperation(OP_and, NULL);
									else if (valor_nodo->type == AST_LOGICO_OU)	aux_code->next = createOperation(OP_or, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_DIF)	aux_code->next = createOperation(OP_cmp_NE, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_IGUAL)	aux_code->next = createOperation(OP_cmp_EQ, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_LE)	aux_code->next = createOperation(OP_cmp_LE, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_GE)	aux_code->next = createOperation(OP_cmp_GE, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_L)	aux_code->next = createOperation(OP_cmp_LT, NULL);
									else if (valor_nodo->type == AST_LOGICO_COMP_G)	aux_code->next = createOperation(OP_cmp_GT, NULL);
									operation = aux_code->next->operation;
									(operation->input)[0] = ra;
									(operation->input)[1] = rb;
									(operation->output)[0] = rc;
									break;		
							
			case AST_IF_ELSE:				ra = currentRegister;
									la = createLabel(NULL);
									lb = createLabel(NULL);
									lc = createLabel(NULL);
					
									code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
					
									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;

									if (nodo->first->next != NULL)
										aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);
									else
										aux_code->next = createOperation(OP_nop, NULL);
									aux_code->next->operation->marker = la;
									while (aux_code->next != NULL) aux_code = aux_code->next;
									aux_code->next = createOperation(OP_jumpI, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									(operation->output)[0] = -45;
									(operation->alterOutput)[0] = lc;

									if (nodo->first->next != NULL && nodo->first->next->next != NULL && ((comp_tree_value_t *) (nodo->first->next->next)->value)->type == AST_ELSE) {
											aux_code->next = criaCodigoFromTree(nodo->first->next->next, isMain);
											aux_code->next->operation->marker = lb;
											while (aux_code->next != NULL) aux_code = aux_code->next;
									}
									else {
											aux_code->next = createOperation(OP_nop, lb);
											aux_code = aux_code->next;
									}
									aux_code->next = createOperation(OP_nop, lc);
									
									if (nodo->last != nodo->first && nodo->last != nodo->first->next && ((comp_tree_value_t *) (nodo->last)->value)->type != AST_ELSE)						
										aux_code->next->next = criaCodigoFromTree(nodo->last, isMain);
									break;
			case AST_FOR:			code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;
								
									ra = currentRegister;
									la = createLabel(NULL);
									lb = createLabel(NULL);
									breakLabel = lb;									
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);

									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
									
									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;



									aux_code->next = criaCodigoFromTree(nodo->first->next->next->next, isMain);
									aux_code->next->operation->marker = la;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = criaCodigoFromTree(nodo->first->next->next, isMain);
									while (aux_code->next != NULL) aux_code = aux_code->next;
							
									ra = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;

									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;

									aux_code->next = createOperation(OP_nop, lb);

									if (nodo->last != nodo->first->next->next->next)						
										aux_code->next->next = criaCodigoFromTree(nodo->last, isMain);
									break;

			case AST_WHILE_DO:		ra = currentRegister;
									la = createLabel(NULL);
									lb = createLabel(NULL);
									breakLabel = lb;
					
									code_list = criaCodigoFromTree(nodo->first, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
					
									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;



									if (nodo->first->next != NULL)
										aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);
									else
										aux_code->next = createOperation(OP_nop, NULL);
									aux_code->next->operation->marker = la;
									while (aux_code->next != NULL) aux_code = aux_code->next;
									
									ra = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first, isMain);
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
					
									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;

									aux_code->next = createOperation(OP_nop, lb);

									
									if (nodo->last != nodo->first->next)						
										aux_code->next->next = criaCodigoFromTree(nodo->last, isMain);
									break;
			case AST_DO_WHILE:		ra = currentRegister;
									la = createLabel(NULL);
									lb = createLabel(NULL);
									breakLabel = lb;
									
									if (nodo->first != NULL)
										code_list = criaCodigoFromTree(nodo->first, isMain);
									else
										code_list = createOperation(OP_nop, NULL);
									code_list->operation->marker = la;
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;
									
									ra = currentRegister;
									aux_code->next = criaCodigoFromTree(nodo->first->next, isMain);
									while (aux_code->next != NULL) aux_code = aux_code->next;

									aux_code->next = createOperation(OP_cbr, NULL);
									aux_code = aux_code->next;
									operation = aux_code->operation;
					
									(operation->input)[0] = ra;
									(operation->output)[0] = -45; // flag para alterOutput
									(operation->output)[1] = -45;  // flag para alterOutput
	
									(operation->alterOutput)[0] = la;
									(operation->alterOutput)[1] = lb;

									aux_code->next = createOperation(OP_nop, lb);

									
									if (nodo->last != nodo->first->next)						
										aux_code->next->next = criaCodigoFromTree(nodo->last, isMain);
									break;
								
			case AST_BREAK: 		code_list = createOperation(OP_jumpI, NULL);
									(code_list->operation->output)[0] = -45;
									(code_list->operation->alterOutput)[0] = breakLabel;
									code_list->next = criaCodigoFromTree(nodo->last, isMain);
									break;
			case AST_ELSE: 			return criaCodigoFromTree(nodo->first, isMain);
									break;


			case AST_ATRIBUICAO:	rc = currentRegister;
									code_list = criaCodigoFromTree(nodo->first->next, isMain);
									aux_code = code_list;
									while (aux_code->next != NULL) aux_code = aux_code->next;


									if (((comp_tree_value_t *) (nodo->first)->value)->type == AST_VETOR_INDEXADO) {
										rb = currentRegister;
										aux_code->next = criaCodigoFromTree(nodo->first->first->next, isMain);
										while (aux_code->next != NULL) aux_code = aux_code->next;

										entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->first->value))->tableEntry)->value;
				
										aux_code->next = createOperation(OP_multI, NULL);
										aux_code = aux_code->next;
										operation = aux_code->operation;
										operation->input[0] = rb;
										if (entry_values->typeSize == 4) 					
											operation->input[1] = 4;
										else
											operation->input[1] = 1;
										ra = createRegister();
										operation->output[0] = ra;

										aux_code->next = createOperation(OP_addI, NULL);
										aux_code = aux_code->next;
										operation = aux_code->operation;
										operation->input[0] = ra;
										operation->input[1] = entry_values->reg_offset;
									if (isMain == 0) operation->input[1] += 12;
										operation->output[0] = ra;
										while (aux_code->next != NULL) aux_code = aux_code->next;
	
										aux_code->next = createOperation(OP_storeA0, NULL);
										aux_code = aux_code->next;
										operation = aux_code->operation;
										if (entry_values->isGlobal)	(operation->output)[0] = -2;
										else (operation->output)[0] = -1;
										(operation->output)[1] = ra;
										(operation->input)[0] = rc;
									}
									else {
										entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;
										aux_code->next = createOperation(OP_storeAI, NULL);
										aux_code = aux_code->next;
										operation = aux_code->operation;
										(operation->input)[0] = rc;
										if (entry_values->isGlobal)	(operation->output)[0] = -2;
										else (operation->output)[0] = -1;
										(operation->output)[1] = entry_values->reg_offset;
										if (isMain == 0) operation->output[1] += 12;	
									}
									
									while (aux_code->next != NULL) aux_code = aux_code->next;
									aux_code->next = criaCodigoFromTree(nodo->first->next->next, isMain);
									break;
							
			case AST_DECLARATION:	entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->next->value))->tableEntry)->value;
									if (entry_values->type == 6) {
										code_list = createOperation(OP_loadAI, NULL);
										operation = code_list->operation;
										if (entry_values->isGlobal)	(operation->input)[0] = -2;
										else (operation->input)[0] = -1;
										(operation->input)[1] = entry_values->reg_offset;
										if (isMain == 0) operation->input[1] += 12;
										(operation->output)[0] = createRegister();
										
										entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;
										
										aux_code = createOperation(OP_storeAI, NULL);
										(aux_code->operation->input)[0] = (operation->output)[0];
										(aux_code->operation->output)[0] = -1;
										(aux_code->operation->output)[1] = entry_values->reg_offset;
										if (isMain == 0) (aux_code->operation->output)[1] += 12;
										code_list->next = aux_code;
										
										aux_code ->next = criaCodigoFromTree(nodo->first->next->next, isMain);	
										
									}
									else {
										code_list = createOperation(OP_loadI, NULL);
										operation = code_list->operation;
										(operation->input)[0] = *((int *) entry_values->tokenvalue);
										(operation->output)[0] = createRegister();
										
										entry_values = (table_values_t *) (((comp_tree_value_t *) (nodo->first->value))->tableEntry)->value;
										
										aux_code = createOperation(OP_storeAI, NULL);
										(aux_code->operation->input)[0] = (operation->output)[0];
										(aux_code->operation->output)[0] = -1;
										(aux_code->operation->output)[1] = entry_values->reg_offset;
										if (isMain == 0) (aux_code->operation->output)[1] += 12;
										code_list->next = aux_code;
										
										aux_code ->next = criaCodigoFromTree(nodo->first->next->next, isMain);	
									}
									break;

			case AST_RETURN: ra = currentRegister;
					 code_list = criaCodigoFromTree(nodo->first, isMain	);
					 aux_code = code_list;
					 while (aux_code->next != NULL) aux_code = aux_code->next;

				   aux_code->next = createOperation(OP_storeAI, NULL);
					 aux_code = aux_code->next;
					 (aux_code->operation->input)[0] = ra;
					 (aux_code->operation->output)[0] = -1;
					 (aux_code->operation->output)[1] = 12;

					if (isMain == 0) {
           rb = currentRegister;
					 aux_code->next = createOperation(OP_loadAI, NULL);
					 aux_code = aux_code->next;
					 (aux_code->operation->input)[0] = -1;
					 (aux_code->operation->input)[1] = 0;
					 (aux_code->operation->output)[0] = createRegister();

					 aux_code->next = createOperation(OP_loadAI, NULL);
					 aux_code = aux_code->next;
					 (aux_code->operation->input)[0] = -1;
					 (aux_code->operation->input)[1] = 4;
					 (aux_code->operation->output)[0] = -3;
					}
					
					 aux_code->next = createOperation(OP_storeAI, NULL);
					 aux_code = aux_code->next;
					 (aux_code->operation->input)[0] = ra;
					 (aux_code->operation->output)[0] = -3;
					 (aux_code->operation->output)[1] =  0;

					if (isMain == 0) {
					 aux_code->next = createOperation(OP_loadAI, NULL);
					 aux_code = aux_code->next;
					 (aux_code->operation->input)[0] = -1;
					 (aux_code->operation->input)[1] = 8;
					 (aux_code->operation->output)[0] = -1;

							 aux_code->next = createOperation(OP_jump, NULL);
							 aux_code = aux_code->next;
							 (aux_code->operation->output)[0] = rb;
					 }
				   break;
	                                 
	}

	return code_list;
	
}

comp_tree_t *fazNodo (int id, comp_dict_item_t *tableEntry) {

	comp_tree_value_t *valor = (comp_tree_value_t *) malloc (sizeof(comp_tree_value_t));	
	
	valor->type = id;

	valor->tableEntry = tableEntry;

	comp_tree_t *nodo = tree_make_node(valor);
/*
	char *name = NULL;

	if (tableEntry != NULL) {
	
		name = malloc (sizeof(tableEntry->key) - 1);
		int stringSize = strlen(tableEntry->key);
		for (int i = 0;	i < stringSize-1; i++)
			name[i] = tableEntry->key[i];
		name[stringSize-1] = '\0';

	}

	gv_declare(id, nodo, name);

	free(name);
*/
	return nodo;

}

int validaExpression(comp_tree_t *nodo) {
	comp_tree_value_t *value = (comp_tree_value_t *) nodo->value;
	int node_type = value->type;
	table_values_t *entryvalues, *aux;
	switch(node_type) {
						case AST_LITERAL: return ((table_values_t *) ((comp_dict_item_t *) value->tableEntry)->value)->type;
						case AST_ARIM_SOMA:
						case AST_ARIM_SUBTRACAO:
						case AST_ARIM_MULTIPLICACAO:
						case AST_ARIM_DIVISAO:	if ((validaExpression(nodo->first) != TYPE_INT && validaExpression(nodo->first) != TYPE_FLOAT)
													|| (validaExpression(nodo->first->next) != TYPE_INT && validaExpression(nodo->first->next) != TYPE_FLOAT))
													quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
												else
													return TYPE_FLOAT;
												break;
						case AST_ARIM_INVERSAO:
												if (validaExpression(nodo->first) != TYPE_INT && validaExpression(nodo->first) != TYPE_FLOAT)
													quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
												else
													return TYPE_FLOAT;
												break;
						case AST_LOGICO_COMP_LE:
						case AST_LOGICO_COMP_GE:
						case AST_LOGICO_COMP_IGUAL:
						case AST_LOGICO_COMP_DIF:
						case AST_LOGICO_COMP_G:
						case AST_LOGICO_COMP_L:	if ((validaExpression(nodo->first) != TYPE_INT && validaExpression(nodo->first) != TYPE_FLOAT)
													|| (validaExpression(nodo->first->next) != TYPE_INT && validaExpression(nodo->first->next) != TYPE_FLOAT))
													quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
												else
													return TYPE_BOOL;
												break;
						case AST_LOGICO_E:
						case AST_LOGICO_OU:	if (validaExpression(nodo->first) != TYPE_BOOL || validaExpression(nodo->first->next) != TYPE_BOOL)
													quit(IKS_ERROR_TYPE_MISMATCH, "Type mismatch.");
												else
													return TYPE_BOOL;
												break;
						case AST_IDENTIFICADOR: aux = ((table_values_t *) ((comp_dict_item_t *) value->tableEntry)->value);
												entryvalues = (table_values_t *) ((getFromTable((char *)aux->tokenvalue, 0))->value);
												if (entryvalues->identType == -1) quit(IKS_ERROR_UNDECLARED, "Identificador não declarado.");
												if (entryvalues->isVector > 0) quit (IKS_ERROR_VECTOR, "Identificador de vetor não foi indexado.");
												if (entryvalues->identType >= TYPE_FUN_INT) quit(IKS_ERROR_FUNCTION, "Identificador de função utilizado errado.");
												aux->reg_offset = entryvalues->reg_offset;
												aux->isGlobal = entryvalues->isGlobal;
												return entryvalues->identType;
						case AST_VETOR_INDEXADO:entryvalues = ((table_values_t *) ((comp_dict_item_t *) ((comp_tree_value_t *) nodo->first->value)->tableEntry)->value);
												entryvalues = (table_values_t *) ((getFromTable((char *)entryvalues->tokenvalue, 0))->value);
												if (entryvalues->identType == -1) quit(IKS_ERROR_UNDECLARED, "Identificador não declarado.");
												if (entryvalues->identType >= TYPE_FUN_INT) quit(IKS_ERROR_FUNCTION, "Identificador de função utilizado errado.");
												if (entryvalues->isVector <= 0) quit (IKS_ERROR_VARIABLE, "Identificador de vetor não foi indexado.");
												if (validaExpression(nodo->first->next) != TYPE_INT && validaExpression(nodo->first->next) != TYPE_FLOAT) quit (IKS_ERROR_TYPE_MISMATCH, "Type Mismatch");
												return entryvalues->identType;
												
						case AST_CHAMADA_DE_FUNCAO:	value = (comp_tree_value_t *) nodo->first->value;
												aux = ((table_values_t *) ((comp_dict_item_t *) value->tableEntry)->value);
												entryvalues = (table_values_t *) ((getFromTable((char *)aux->tokenvalue, 0))->value);
												return entryvalues->identType - 6;
						default:		
										break;
						}
}

void conectaNodo (comp_tree_t *pai, comp_tree_t *filho) {

	if (filho == NULL)
		return;
	
	tree_insert_node(pai, filho);	

	//gv_connect(pai, filho);

}
