%{
#include <stdio.h>
#include "lex.yy.h"

int yylex(void);

void yyerror (char const *s);
extern int get_line_number();
%}


%token <token.type> INT
%token <token.type> FLOAT
%token <token.type> BOOL
%token <token.type> CHAR
%token <token.type> STRING
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token INPUT
%token OUTPUT
%token RETURN
%token CONST
%token STATIC
%token FOREACH
%token FOR
%token SWITCH
%token CASE
%token BREAK
%token CONTINUE
%token CLASS
%token PRIVATE
%token PUBLIC
%token PROTECTED
%token <token.type> LE_OP
%token <token.type> GE_OP
%token <token.type> EQ_OP
%token <token.type> NE_OP
%token <token.type> AND_OP
%token <token.type> OR_OP
%token <token.type> SL_OP
%token <token.type> SR_OP
%token <token.type> FORWARD_PIPE
%token <token.type> BASH_PIPE
%token <token> INT_LITERAL
%token <token> FLOAT_LITERAL
%token <token> FALSE
%token <token> TRUE
%token <token> CHAR_LITERAL
%token <token> STRING_LITERAL
%token <token> ID
%token <token.type> '+'
%token <token.type> '-'
%token <token.type> '!'
%token <token.type> '*'
%token <token.type> '&'
%token <token.type> '?'
%token <token.type> '#'
%token <token.type> '^'
%token <token.type> '/'
%token <token.type> '%'
%token <token.type> '>'
%token <token.type> '<'
%token <token.type> '|'
%token ERROR

%%

program
    : %empty //{ $$ = 0; }
    | unit// { $$ = $1; }
    ;

unit
    : element
    | unit element //{ $$ = make_unit($1, $2); }
    ;

element
    : global_var_declaration ';'
    | class_definition ';'
    | function_definition
    ;

global_var_declaration
    : ID primitive_type_specifier //{      //  $$ = make_global_var_decl($1, -1, false, make_primitive($2)); }
    | ID ID //{      //  $$ = make_global_var_decl($1, -1, false, make_custom($2.val.string_v)); }
    | ID array static_modifier type_specifier        // {$$ = make_global_var_decl($1, $2, $3, $4); }
    | ID STATIC type_specifier// {        //$$ = make_global_var_decl($1, -1, true, $3); }
    ;

array
    : '[' INT_LITERAL ']' //{ $$ = $2.val.int_v; }
    ;

static_modifier
    : %empty //{ $$ = false; }
    | STATIC// { $$ = true; }
    ;

const_modifier
    : %empty// { $$ = false; }
    | CONST //{ $$ = true; }
    ;

type_specifier
    : primitive_type_specifier //{ $$ = make_primitive($1); }
    | ID //{ $$ = make_custom($1.val.string_v); }
    ;

primitive_type_specifier
    : INT
    | FLOAT
    | BOOL
    | CHAR
    | STRING
    ;

class_definition
    : CLASS ID '[' field_list ']' //{ $$ = make_class_def($2, $4); }
    ;

field_list
    : field
    | field ':' field_list //{ $1->val.field.next = $3; $$ = $1; }
    ;

field
    : access_modifier primitive_type_specifier ID //{        //$$ = make_field($1, make_primitive($2), $3); }
    ;

access_modifier
    : %empty //{ $$ = NONE; }
    | PRIVATE //{ $$ = PRIV; }
    | PUBLIC //{ $$ = PUB; }
    | PROTECTED //{ $$ = PROT; }
    ;

////// AHFG 4553
function_definition
    : primitive_type_specifier ID parameters command_block //{        //$$ = make_function_def(false, make_primitive($1), $2, $3, $4); }
    | ID ID parameters command_block //{        //$$ = make_function_def(false, make_custom($1.val.string_v), $2, $3, $4); }
    | STATIC type_specifier ID parameters command_block //{        //$$ = make_function_def(true, $2, $3, $4, $5); }
    ;

parameters
    : '(' ')' //{ $$ = 0; }
    | '(' parameter_list ')' //{ $$ = $2; }
    ;

parameter_list
    : parameter
    | parameter ',' parameter_list //{ $1->val.parameter.next = $3; $$ = $1; }
    ;

parameter
    : const_modifier type_specifier ID //{        $$ = make_parameter($1, $2, $3); }
    ;

command_block
    : '{' '}' //{ $$ = make_cmd_block(0); }
    | '{' high_command_list '}' //{ $$ = make_cmd_block($2); }
    ;

high_command_list
    : high_command
    | high_command_list high_command //{ $$ = make_high_list($1, $2); }
    ;

high_command
    : command ';'
    | output ';'
    | case
    ;

command_list
    : command
    | command_list ',' command //{ $$ = make_cmd_list($1, $3); }
;

command
    : local_var_declaration
    | modifier_local_var_declaration
    | variable_attribution
    | shift
    | return
    | BREAK //{ $$ = make_break_cmd(); }
    | CONTINUE //{ $$ = make_continue_cmd(); }
    | input
    | conditional_statement
    | function_call
    | foreach
    | for
    | while
    | do_while
    | switch
    | command_block
    ;

local_var_declaration
    : primitive_var_declaration
    | class_var_declaration
    ;

modifier_local_var_declaration
    : STATIC const_modifier local_var_declaration //{        $$ = add_decl_modifier(true, $2, $3); }
    | CONST local_var_declaration //{ $$ = add_decl_modifier(false, true, $2); }
    ;

primitive_var_declaration
    : primitive_type_specifier ID local_var_initialization //{        $$ = make_var_decl($1, $2, $3); }
    ;

local_var_initialization
    : %empty //{ $$ = 0; }
    | LE_OP local_var_initializer //{ $$ = $2; }
    ;

local_var_initializer
    : variable
    | literal
    ;

literal
    : INT_LITERAL// {       // $$ = make_literal($1); }
    | FLOAT_LITERAL //{       // $$ = make_literal($1); }
    | FALSE //{       // $$ = make_literal($1); }
    | TRUE //{       // $$ = make_literal($1); }
    | CHAR_LITERAL //{       // $$ = make_literal($1); }
    | STRING_LITERAL //{        //$$ = make_literal($1); }
    ;

class_var_declaration
    : ID ID //{ $$ = make_class_var_decl($1.val.string_v, $2); }
    ;

variable_attribution
    : variable '=' expression //{ $$ = make_attr_cmd($1, $3); }
    ;

variable
    : ID //{ $$ = make_var($1, 0, 0); }
    | ID '$' ID //{ $$ = make_var($1, $3.val.string_v, 0); }
    | ID '[' expression ']' //{ $$ = make_var($1, 0, $3); }
    | ID '[' expression ']' '$' ID //{ $$ = make_var($1, $6.val.string_v, $3); }
    ;

shift
    : variable shift_op expression //{ $$ = make_shift_cmd($1, $2, $3); }
    ;

shift_op
    : SL_OP
    | SR_OP
    ;

return
    : RETURN expression //{ $$ = make_return_cmd($2); }
    ;

case
    : CASE INT_LITERAL ':' //{ $$ = make_case_label($2.val.int_v); }
    ;

input
    : INPUT expression// { $$ = make_in_cmd($2); }
;
output
    : OUTPUT expression_list //{ $$ = make_out_cmd($2); }
    ;

conditional_statement
    : IF '(' expression ')' THEN command_block else_statement //{        $$ = make_if_cmd($3, $6, $7); }
    ;

else_statement
    : %empty//{ $$ = 0; }
    | ELSE command_block //{ $$ = $2; }
    ;

function_call
    : function
    | function_call pipe function //{ $$ = make_pipe_cmd($1, $2, $3); }
    ;

function
    : ID '(' argument_list ')'// { $$ = make_function_cmd($1, $3); }
    ;

pipe
    : FORWARD_PIPE
    | BASH_PIPE
    ;

argument_list
    : %empty //{ $$ = 0; }
    | argument// { $$ = make_arg_list($1, 0); }
    | argument ',' argument_list //{ $$ = make_arg_list($1, $3); }
    ;

argument
    : '.' //{ $$ = make_dot_arg(); }
    | expression
    ;

foreach
    : FOREACH '(' ID ':' expression_list ')' command_block //{        $$ = make_foreach_cmd($3.val.string_v, $5, $7); }
    ;

for
    : FOR '(' command_list ':' expression ':' command_list ')' command_block //{        $$ = make_for_cmd($3, $5, $7, $9); }
    ;

while
    : WHILE '(' expression ')' DO command_block //{ $$ = make_while_cmd($3, $6); }
    ;

do_while
    : DO command_block WHILE '(' expression ')' //{        $$ = make_do_while_cmd($2, $5); }
;
switch
    : SWITCH '(' expression ')' command_block //{ $$ = make_switch_cmd($3, $5); }
    ;

expression_list
    : expression //{ $$ = make_exp_list($1, 0); }
    | expression ',' expression_list //{ $$ = make_exp_list($1, $3); }
    ;

expression
    : pipe_exp
    ;

pipe_exp
    : ternary_exp
    | pipe_exp FORWARD_PIPE ternary_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | pipe_exp BASH_PIPE ternary_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

ternary_exp
    : logical_or_exp
    | logical_or_exp '?' expression ':' ternary_exp //{        $$ = make_ternary_exp($1, $3, $5); }
    ;

logical_or_exp
    : logical_and_exp
    | logical_or_exp OR_OP logical_and_exp //{        $$ = make_binary_exp($1, $2, $3); }
    ;

logical_and_exp
    : bitwise_or_exp
    | logical_and_exp AND_OP bitwise_or_exp //{        $$ = make_binary_exp($1, $2, $3); }
    ;

bitwise_or_exp
    : bitwise_and_exp
    | bitwise_or_exp '|' bitwise_and_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

bitwise_and_exp
    : equality_exp
    | bitwise_and_exp '&' equality_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

equality_exp
    : relational_exp
    | equality_exp EQ_OP relational_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | equality_exp NE_OP relational_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

relational_exp
    : additive_exp
    | relational_exp '<' additive_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | relational_exp '>' additive_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | relational_exp LE_OP additive_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | relational_exp GE_OP additive_exp// { $$ = make_binary_exp($1, $2, $3); }
    ;

additive_exp
    : multiplicative_exp
    | additive_exp '+' multiplicative_exp //{ $$ = make_binary_exp($1, $2, $3); }
    | additive_exp '-' multiplicative_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

multiplicative_exp
    : exponentiation_exp
    | multiplicative_exp '*' exponentiation_exp// {        $$ = make_binary_exp($1, $2, $3); }
    | multiplicative_exp '/' exponentiation_exp //{        $$ = make_binary_exp($1, $2, $3); }
    | multiplicative_exp '%' exponentiation_exp //{        $$ = make_binary_exp($1, $2, $3); }
    ;

exponentiation_exp
    : unary_exp
    | exponentiation_exp '^' unary_exp //{ $$ = make_binary_exp($1, $2, $3); }
    ;

unary_exp
    : operand
    | unary_operator unary_exp //{ $$ = make_unary_exp($1, $2); }
    ;

unary_operator
    : '+'
    | '-'
    | '!'
    | '*'
    | '&'
    | '?'
    | '#'
    ;

operand
    : variable
    | literal
    | function
    | '(' expression ')' //{ $$ = $2; }
    ;

%%

void yyerror(struct node** node, char const *s) {
    (void)node;

    is_invalid = true;
    char error[] = "Unexpected token: %s at line %d column %d\n";
    fprintf(stderr, error, yytext, get_line_number(), get_column_number());
}
