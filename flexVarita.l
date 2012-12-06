%{
#include "ex1.tab.h"
#include <stdio.h>
%}

%option noyywrap

%%

a  { yylval.sym = yytext[0]; 
      return a; }
b  { yylval.sym = yytext[0];
      return b; }
c  { yylval.sym = yytext[0];
      return c; }
d  { yylval.sym = yytext[0];
      return d; }

; { yylval.sym = yytext[0];
      return STOP; }

<<EOF>>  { return 0; }
[ \t\n]+ { }
.        { 
          printf("NO ES UN ATAQUE");
          }
%%

