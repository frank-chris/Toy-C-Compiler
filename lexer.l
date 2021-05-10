
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
"[" {printf("LBRACK\n"); return LBRACK;}
"]" {printf("RBRACK\n"); return RBRACK;}
"(" {printf("LPAREN\n"); return LPAREN;}
")" {printf("RPAREN\n"); return RPAREN;}
"if" {printf("IF\n"); return IF;}
"else" {printf("ELSE\n"); return ELSE;}
"for" {printf("FOR\n"); return FOR;}
"while" {printf("WHILE\n"); return WHILE;}
"do" {printf("DO\n"); return DO;}
"true" {printf("TRUE\n"); return TRUE;}
"false" {printf("FALSE\n"); return FALSE;}
"scan" {printf("SCAN\n"); return SCAN;}
"print" {printf("PRINT\n"); return PRINT;}
"start" {printf("START\n"); return START;}
"end" {printf("END\n"); return END;}
"return" {printf("RETURN"); return RETURN;}
"label" {printf("LABEL\n"); return LABEL;}
"goto" {printf("GOTO\n"); return GOTO;}
{id} {printf("ID\n"); sprintf(yylval.var, "%s", yytext); return VAR;}
{number} {printf("NUM\n"); sscanf(yytext,"%d",&yylval.val); return NUM;}
";" {printf("SEMICOLON\n"); return SEMICOLON;}
"," {printf("COMMA\n"); return COMMA;}
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

"+" {printf("PLUS\n"); yylval.arithmetic_type=10; return PLUS;}
"-" {printf("MINUS\n"); yylval.arithmetic_type=11; return MINUS;}
"*" {printf("TIMES\n"); yylval.arithmetic_type=12; return TIMES;}
"/" {printf("DIVIDE\n"); yylval.arithmetic_type=13; return DIVIDE;}
"%" {printf("MODULUS\n"); yylval.arithmetic_type=14; return MODULUS;}

[ \n\t] {}
. {printf("error:Character %s\n",yytext);exit(0);}

%%

