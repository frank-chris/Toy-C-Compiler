
%{
#include "parser.tab.h"
#include "parser.h"
#include <stdio.h>
#include <stdlib.h>

// int Adr=0;
// symrec *sym_table = (symrec *)0;
%}
digit [0-9]
number {digit}+
letter [a-zA-Z_]
id {letter}({letter}|{digit})*

%%

[ ] {}
"{" {printf("LBRACE\n");return LBRACE;}
"}" {printf("RBRACE\n");return RBRACE;}
"(" {printf("LPAREN\n");return LPAREN;}
")" {printf("RPAREN\n");return RPAREN;}
"if" {printf("IF\n");return IF;}
"else" {printf("ELSE\n");return ELSE;}
"for" {printf("FOR\n");return FOR;}
"while" {printf("WHILE\n");return WHILE;}
"true" {printf("TRUE\n");return TRUE;}
"false" {printf("FALSE\n");return FALSE;}
{id} {printf("ID\n");symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR); yylval.tptr=s; return VAR;}
{number} {printf("NUM\n"); sscanf(yytext,"%d",&yylval.val); return NUM;}
";" {printf("SEMICOLON\n");return SEMICOLON;}
":=" {printf("DEFINE\n");return DEFINE;}
"=" {printf("ASSIGN\n");return ASSIGN;}

"<"   {printf("LT\n");yylval.relop_type=1;return RELOP;}
">"   {printf("GT\n");yylval.relop_type=2;return RELOP;}
"<="   {printf("LE\n");yylval.relop_type=3;return RELOP;}
">="   {printf("GE\n");yylval.relop_type=4;return RELOP;}
"=="   {printf("EQ\n");yylval.relop_type=5;return RELOP;}

"&&" {printf("AND\n");return AND;}
"||" {printf("OR\n");return OR;}

"+" {printf("PLUS\n");return PLUS;}
"-" {printf("MINUS\n");return MINUS;}
"*" {printf("TIMES\n");return TIMES;}
"/" {printf("DIVIDE\n");return DIVIDE;}

[ \n\t] {}
. {printf("error:Character %s\n",yytext);exit(0);}

%%
