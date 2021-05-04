
%{
#include "parser.tab.h"
#include "parser.h"
#include <stdio.h>
#include <stdlib.h>

%}
digit [0-9]
number {digit}+
letter [a-zA-Z_]
id {letter}({letter}|{digit})*

%%

[ ] {}
"{" {printf("LBRACE\n"); return LBRACE;}
"}" {printf("RBRACE\n"); return RBRACE;}
"(" {printf("LPAREN\n"); return LPAREN;}
")" {printf("RPAREN\n"); return RPAREN;}
"if" {printf("IF\n"); return IF;}
"else" {printf("ELSE\n"); return ELSE;}
"for" {printf("FOR\n"); return FOR;}
"while" {printf("WHILE\n"); return WHILE;}
"true" {printf("TRUE\n"); return TRUE;}
"false" {printf("FALSE\n"); return FALSE;}
{id} {printf("ID\n");symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR); yylval.tptr=s; return VAR;}
{number} {printf("NUM\n"); sscanf(yytext,"%d",&yylval.val); return NUM;}
";" {printf("SEMICOLON\n"); return SEMICOLON;}
":=" {printf("DEFINE\n"); return DEFINE;}
"=" {printf("ASSIGN\n"); return ASSIGN;}

"<"   {printf("LT\n"); yylval.relational_type=1; return RELATIONAL;}
">"   {printf("GT\n"); yylval.relational_type=2; return RELATIONAL;}
"<="   {printf("LE\n"); yylval.relational_type=3; return RELATIONAL;}
">="   {printf("GE\n"); yylval.relational_type=4; return RELATIONAL;}
"=="   {printf("EQ\n"); yylval.relational_type=5; return RELATIONAL;}
"!="   {printf("NE\n"); yylval.relational_type=6; return RELATIONAL;}

"&" {printf("AND\n"); yylval.logical_type=7; return LOGICAL;}
"|" {printf("OR\n"); yylval.logical_type=8; return LOGICAL;}
"^" {printf("XOR\n"); yylval.logical_type=9; return LOGICAL;}

"+" {printf("PLUS\n"); yylval.arithmetic_type=10; return ARITHMETIC;}
"-" {printf("MINUS\n"); yylval.arithmetic_type=11; return ARITHMETIC;}
"*" {printf("TIMES\n"); yylval.arithmetic_type=12; return ARITHMETIC;}
"/" {printf("DIVIDE\n"); yylval.arithmetic_type=13; return ARITHMETIC;}
"%" {printf("MODULUS\n"); yylval.arithmetic_type=13; return ARITHMETIC;}

[ \n\t] {}
. {printf("error:Character %s\n",yytext);exit(0);}

%%

