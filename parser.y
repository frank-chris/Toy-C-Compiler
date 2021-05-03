%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "parser.h"  /* Contains definition of `symrec'        */
int  yylex(void);
void yyerror (char  *);
int whileStart=0,nextJump=0; /*two separate variables not necessary for this application*/
int count=0;
int labelCount=0;
FILE *fp;
struct StmtsNode *final;
void StmtsTrav(stmtsptr ptr);
void StmtTrav(stmtptr ptr);
%}
%union {
int   val;  /* For returning numbers.                   */
int relop_type; /*Type of relop */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
char c[1000];
char nData[100];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}

%token  <val> NUM        /* Integer   */
%token <val> RELOP
%token  WHILE
%token <tptr> VAR   
%type  <c>  exp
%type  <c>  bool_exp
%type <nData> x
%type <stmtsptr> stmts
%type <stmtptr> stmt

%right '='
%left '-' '+'
%left '*' '/'

