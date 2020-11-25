
%output "parser.c"
%defines "parser.h"
%define parse.error verbose
%define parse.lac full

%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include "tables.h"

int yylex();
int yylex_destroy(void);
void yyerror(const char *s);

void check_var();
void new_var();

void check_fun();
int new_fun();
int escopo;
int aridade;

extern char *yytext;
char *yyfunc;
extern int yylineno;

StrTable *st;
VarTable *vt;
VarTable *ft;

%}

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE
%token SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token ASSIGN
%token LT LE GT GE EQ NEQ

%token NUM
%token ID
%token STRING

%left PLUS MINUS
%left TIMES OVER

%start program

%%

program:
  func_decl_list
;

func_decl_list:
  func_decl_list func_decl
| func_decl
;

func_decl:
  func_header func_body {escopo=escopo+1;}
;

func_header:
  ret_type ID {yyfunc = yytext;} LPAREN params RPAREN 
;

func_body:
  LBRACE opt_var_decl opt_stmt_list RBRACE
;

opt_var_decl:
  %empty
| var_decl_list
;

opt_stmt_list:
  %empty
| stmt_list 
;

ret_type:
  INT
| VOID
;

params:
  VOID  {aridade=0;}
| param_list 
;

param_list:
  param_list COMMA param  {aridade=aridade+1;}
| param  {aridade=1;}
;

param:
  INT ID {new_var();}
| INT ID {new_var();} LBRACK RBRACK 
;

var_decl_list:
  var_decl_list var_decl
| var_decl
;

var_decl:
  INT ID {new_var();} SEMI
| INT ID {new_var();} LBRACK NUM RBRACK SEMI 
;

stmt_list:
  stmt_list stmt 
| stmt
;

stmt:
  assign_stmt    
| if_stmt        
| while_stmt     
| return_stmt    
| func_call SEMI 
;

assign_stmt:
  lval ASSIGN arith_expr SEMI
;

lval:
  ID  {check_var();}
| ID LBRACK NUM RBRACK  {check_var();}
| ID LBRACK {check_var();} ID {check_var();} RBRACK 
;

if_stmt:
  IF LPAREN bool_expr RPAREN block
| IF LPAREN bool_expr RPAREN block ELSE block
;

block:
  LBRACE opt_stmt_list RBRACE 
;

while_stmt:
  WHILE LPAREN bool_expr RPAREN block
;

return_stmt:
  RETURN SEMI
| RETURN arith_expr SEMI
;

func_call:
  output_call     
| write_call      
| user_func_call  
;

input_call:
  INPUT LPAREN RPAREN
;

output_call:
  OUTPUT LPAREN arith_expr RPAREN
;

write_call:
  WRITE LPAREN STRING RPAREN
;

user_func_call:
  ID {yyfunc = yytext;} LPAREN opt_arg_list RPAREN  {check_fun();}
;

opt_arg_list:
  %empty  {aridade=0;}
| arg_list 
;

arg_list:
  arg_list COMMA arith_expr  {aridade++;}
| arith_expr   {aridade=1;}
;

bool_expr:
  arith_expr LT arith_expr
| arith_expr LE arith_expr
| arith_expr GT arith_expr
| arith_expr GE arith_expr
| arith_expr EQ arith_expr
| arith_expr NEQ arith_expr
;

arith_expr:
  arith_expr PLUS arith_expr     
| arith_expr MINUS arith_expr
| arith_expr TIMES arith_expr
| arith_expr OVER arith_expr 
| LPAREN arith_expr RPAREN
| lval 
| input_call
| user_func_call 
| NUM
;

%%

void check_var() {
    int idx = lookup_var(vt, yytext, escopo);
    if (idx == -1) {
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", yylineno, yytext);
        exit(EXIT_FAILURE);
    }
}

void new_var() {
    int idx = lookup_var(vt, yytext, escopo);
    if (idx != -1) {
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", yylineno, yytext, get_line(vt, idx));
        exit(EXIT_FAILURE);
    }
    add_var(vt, yytext, yylineno, escopo);
}


void check_fun() {
    int idx = lookup_fun(ft, yyfunc);
    if (idx == -1) {
        printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n", yylineno, yyfunc);
        exit(EXIT_FAILURE);
    }
    if(get_aridade(ft, idx) != aridade ) {
        printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n",
                yylineno, yytext, aridade, get_aridade(ft, idx));
        exit(EXIT_FAILURE);
    }
}


// Primitive error handling.
void yyerror (char const *s) {
    printf("SYNTAX ERROR (%d): %s\n", yylineno, s);
    exit(EXIT_FAILURE);
}

int main() {
    st = create_str_table();
    vt = create_var_table();
    ft = create_var_table();
    escopo = 0;

    yyparse();
    printf("PARSE SUCCESSFUL!\n");

    printf("\n\n");
    print_str_table(st); printf("\n\n");
    print_var_table(vt); printf("\n\n");
    print_fun_table(ft); printf("\n\n");

    free_str_table(st);
    free_var_table(vt);
    free_var_table(ft);
    yylex_destroy();    // To avoid memory leaks within flex...

    return 0;
}