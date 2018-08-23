/*
	 Grupo Zeta
*/
%{
#include "string.h"


int num_lines = 1;
char errorAux[2];
%}


%x comment
%x error

%%

[ \t]

int	  return TK_PR_INT;
float	  return TK_PR_FLOAT;
bool	  return TK_PR_BOOL;
char	  return TK_PR_CHAR;
string	  return TK_PR_STRING;
if	  return TK_PR_IF;
then	  return TK_PR_THEN;
else	  return TK_PR_ELSE;
while	  return TK_PR_WHILE;
do	  return TK_PR_DO;
input	  return TK_PR_INPUT;
output	  return TK_PR_OUTPUT;
return	  return TK_PR_RETURN;
const	  return TK_PR_CONST;
static	  return TK_PR_STATIC;
foreach	  return TK_PR_FOREACH;
for	  return TK_PR_FOR;
switch	  return TK_PR_SWITCH;
case	  return TK_PR_CASE;
break	  return TK_PR_BREAK;
continue  return TK_PR_CONTINUE;
class	  return TK_PR_CLASS;
private	  return TK_PR_PRIVATE;
public	  return TK_PR_PUBLIC;
protected return TK_PR_PROTECTED;

"<="	return TK_OC_LE;
">="	return TK_OC_GE;
"=="	return TK_OC_EQ;
"!="	return TK_OC_NE;
"&&"	return TK_OC_AND;
"||"	return TK_OC_OR;
">>"	return TK_OC_SR;
"<<"	return TK_OC_SL;
"%>%"	return TK_OC_PIP;
"%|%"	return TK_OC_OOR;

|";"|":"|"("|")"|"["|"]"|"{"|"}"|"+"|"-"|"*"|"/"|"<"|">"|"="|"!"|"&"|"%"|"#"|"^"|"."    return yytext[0];

[E][+|-]?[0-9]+  {  yylval.valor_lexico = (comp_dict_item_t *) insert_dict(table, yytext, num_lines, POA_LIT_FLOAT); return TK_LIT_FLOAT;}

[0-9]+    {  return TK_LIT_INT;}

[0-9]+"."[0-9]* {   return TK_LIT_FLOAT;}

false   {   return TK_LIT_FALSE;}
true    {   return TK_LIT_TRUE;}

'[^']'  {  return TK_LIT_CHAR;}

\"(\\.|[^"\\])*\"  {  return TK_LIT_STRING;}

[_a-zA-Z][_a-zA-Z0-9]* {   return TK_IDENTIFICADOR;}


"/*"		BEGIN(comment);

<comment>[^*\n]*
<comment>"*"+[^*/\n]*
<comment>\n		   num_lines++;
<comment>"*"+"/"	   BEGIN(INITIAL);

"//"[^\n]*

\n 	++num_lines;

[0-9]+[a-zA-Z_][a-zA-Z_0-9]* 	return TOKEN_ERRO;

.	 {errorAux[0] = yytext[0]; BEGIN(error);}
<error>[\t ] {
	BEGIN(INITIAL);
	yyerror("Erro localizado na linha");
	yytext--;
	return TOKEN_ERRO;
	}
<error>[\n] {
	BEGIN(INITIAL);
	yyerror("Erro localizado na linha");
	errorAux[1] = '\n';
	num_lines++;
	yytext--;
	return TOKEN_ERRO;
	}

<error>[^\n \t]* {
	BEGIN(INITIAL);
	yyerror("Erro localizado na linha");
	errorAux[0] = '\0';
	yytext--;
	return TOKEN_ERRO;
	}


%%

