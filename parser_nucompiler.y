/* 
	Grupo Nu:
		Arthur Marques Medeiros - 261587
		Luiz Miguel Krüger - 228271
*/

%code requires {
#include "main.h"
}

%{
#include "main.h"
#include "string.h"


extern comp_tree_t *syntaxTree;
int currentLabel = 0;
FILE *fp = NULL;


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


%union {
  comp_dict_item_t *valor_lexico;
  comp_tree_t *nodo_arvore;
  int type;
}

%%
/* Regras (e ações) da gramática */


programa: Element 
;

Element: GVarDeclaration Element
| TypeDeclaration Element
| FunDeclaration Element 
| %empty 		
;

FunDeclaration: Header CommandBlock
;

Header: Static Type TK_IDENTIFICADOR '(' EntryParams ')'
;

EntryParams: Const Type TK_IDENTIFICADOR ',' EntryParams	


| Const Type TK_IDENTIFICADOR								
;

CommandBlock: '{' Scope Commands NoScope '}' 
| '{' Scope NoScope '}'
;

Scope : %empty
;

NoScope : %empty 
;

Commands: Command ';' Commands 
| Command	';'
;


Command: VarDeclaration
| FunctionCall 
| Attribution
| Input	
| Output 
| ShiftExp 
| Return
| Break	
| Continue
| If	
| While	
| For	
| ForEach
| Switch
| CommandBlock
| PipeExpr	
| Case 		
;

Case : TK_PR_CASE Literal ':' CommandBlock

If: TK_PR_IF '(' Expression ')' TK_PR_THEN CommandBlock	
| TK_PR_IF '(' Expression ')' TK_PR_THEN CommandBlock TK_PR_ELSE CommandBlock  ;

While: TK_PR_WHILE '(' Expression ')' TK_PR_DO CommandBlock	
| TK_PR_DO CommandBlock TK_PR_WHILE '(' Expression ')'		
;

For: TK_PR_FOR Scope '(' ForList ':' Expression ':' ForList ')' '{' Commands NoScope '}'
;

ForList: CommandFor ',' ForList		
| CommandFor				
;

CommandFor: VarDeclaration 	
| FunctionCall 	
| Attribution 	
| ShiftExp 		
| Return 	
| Break 	
| Continue 	
| If		
| While		
| For		
| ForEach	
| CommandBlock	
| Switch	
| PipeExpr 	
;

ForEach: TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' ForEachList ')' CommandBlock	
;

ForEachList: Expression ',' ForEachList				
| Expression							
;

Switch: TK_PR_SWITCH '(' Expression ')' CommandBlock		
;

Return: TK_PR_RETURN Expression	
;
		
Break: TK_PR_BREAK
;

Continue: TK_PR_CONTINUE
;

ShiftExp: TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT	
| TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT		
;

Input: TK_PR_INPUT Expression
;

Output: TK_PR_OUTPUT OutputList
;

OutputList: Expression ',' OutputList
| Expression
;

Attribution: TK_IDENTIFICADOR '=' Expression
| TK_IDENTIFICADOR '[' Expression ']' '=' Expression															
| TK_IDENTIFICADOR '.' TK_IDENTIFICADOR '=' Expression	
;

Expression: AritExpr
| LogExpr		
| PipeExpr		
| NewLogExpr		
;

AritExpr: AritExpr '+' AritExpr
| AritExpr '-' AritExpr		
| AritExpr '*' AritExpr		
| AritExpr '/' AritExpr		
| '+' AritExpr			
| '-' AritExpr			
| '(' AritExpr ')'		
| Operands			
;

LogExpr:  AritExpr TK_OC_LE AritExpr 
| AritExpr TK_OC_GE AritExpr		
| AritExpr TK_OC_EQ AritExpr		
| AritExpr TK_OC_NE AritExpr		
| AritExpr '>' AritExpr			
| AritExpr '<' AritExpr			
| '(' LogExpr ')'			
;

NewLogExpr: LogExpr TK_OC_AND LogExpr	
| LogExpr TK_OC_OR LogExpr		
| '(' NewLogExpr ')'			
;

PipeExpr:  FunctionCall PipeTokens PipeRecursion 
;

PipeRecursion: FunctionCall PipeTokens PipeRecursion
| FunctionCall						
;

PipeTokens: TK_OC_PIP
| TK_OC_OOR		
;

Operands: TK_IDENTIFICADOR ArraySizeExp 
| Literal	
| FunctionCall	
;

FunctionCall: TK_IDENTIFICADOR '(' CallParams ')'
| TK_IDENTIFICADOR '(' ')'
;

CallParams: Expression ',' CallParams
| '.' ',' CallParams
| '.'
| Expression
;

VarDeclaration: TK_PR_STATIC VarDeclaration1
| VarDeclaration1				
;

VarDeclaration1: TK_PR_CONST VarDeclaration2
| VarDeclaration2
;

VarDeclaration2: TK_IDENTIFICADOR TK_IDENTIFICADOR
| PrimType TK_IDENTIFICADOR RightAttr	
;

RightAttr: TK_OC_LE TK_IDENTIFICADOR
| TK_OC_LE Literal			
| %empty 				
;

Literal: TK_LIT_INT
| TK_LIT_FLOAT	
| TK_LIT_FALSE	
| TK_LIT_TRUE	
| TK_LIT_CHAR	
| TK_LIT_STRING	
;

Const: TK_PR_CONST
| %empty
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

GVarDeclaration: Static Type TK_IDENTIFICADOR ArraySize ';' 
;

Static: TK_PR_STATIC
| %empty	
;

ArraySize: '[' TK_LIT_INT ']'
| %empty
;

ArraySizeExp: '[' Expression ']' 
| %empty
;

Type: PrimType
| TK_IDENTIFICADOR
;

PrimType: TK_PR_FLOAT
| TK_PR_INT
| TK_PR_CHAR
| TK_PR_STRING
| TK_PR_BOOL
;

%%

	
