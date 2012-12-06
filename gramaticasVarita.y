%{
#include <stdio.h>
#include <string.h>

//Lexer prototype required by bison, aka getNextToken()
int yylex(); 
int yyerror(const char *p) { printf("Error"); }
%}

//SYMBOL SEMANTIC VALUES
%union {
  char sym;
};
%token <sym> a b c d STOP
%type  <sym> A B C D E

//GRAMMAR RULES

%%
run: | run E | run error   /* forces bison to process many stmts */
E: A C D B STOP { printf("U"); }
E: A C STOP { printf("Linea vertical (Lado izq)"); }
E: C A B D STOP { printf("Escalón"); }

A: a A | a
B: b B | b
C: c C | c
D: d D | d
%%

//FUNCTION DEFINITIONS
int main()
{
  yyparse();
  return 0;
}
