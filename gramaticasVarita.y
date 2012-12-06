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
E: C D B STOP { printf("L reflejada horizontalmente"); }
E: B A C STOP { printf("L reflejada verticalmente"); }
E: A B STOP { printf("Línea horizontal"); }
E: A C D B STOP { printf("U"); }
E: A C STOP { printf("Linea vertical (Lado izq)"); }
E: C A B D STOP { printf("Escalón"); }
E: A C D STOP { printf ("L (normal)"); }
E: A B D STOP { printf ("L inversa");}
E: B D STOP { printf("Línea vertial (lado derecho"); }

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
