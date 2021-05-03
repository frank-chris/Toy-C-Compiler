%{

#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "parser.h"  /* Contains definition of `symrec'        */

int count = 0;
int labelCount = 0;
FILE *fp;
struct StmtsNode *final;
void StmtsTrav(stmtsptr ptr);
void StmtTrav(stmtptr ptr);
%}
%union {
int val;  /* For returning numbers.                   */
int relop_type; /*Type of relop */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
char c[1000];
char nData[100];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}

%token LBRACE RBRACE LPAREN RPAREN
%token TRUE FALSE
%token  <val> NUM        /* Integer   */
%token <val> RELOP
%token  WHILE IF ELSE
%token <tptr> VAR   
%type  <c>  exp
%type  <c>  bool_exp
%type <nData> x
%type <stmtsptr> stmts
%type <stmtptr> stmt
%type <stmtptr> assign_stmt if_stmt while_stmt

%right '='
%left '-' '+'
%left '*' '/'

// The Grammar

/* Key points / Invariants
1) Every expression has associated with it machine code such that it ensures that the value of the expression is loaded into the register t0.
*/

%%

prog:
    stmts{ 
    final = $1;
    }

stmts:
     | stmt ';' stmts{
     $$ = (struct StmtsNode *) malloc(sizeof(struct StmtsNode));
     $$ -> singl = 1;
     $$ -> left = $1, $$ -> right = NULL;
     }
     ;

stmt:
    assign_stmt{
    $$ = $1;
    }
    |
    if_stmt{
    $$ = $1;
    }
    |
    while_stmt{
    $$ = $1;
    }
    ;
    
assign_stmt:
           VAR '=' exp{
           $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
           $$ -> type = 0; // type = 0 for assignment
           sprintf($$ -> assgnCode, "%s\nsw $t0,%s($t8)\n", $3, $1 -> addr); // $3 will be t0, its value will be stored at the address(mem location) of the variable.
           $$ -> while_body = NULL;
           $$ -> if_body = NULL;
           $$ -> else_body = NULL;
           }
           |
           error{
           yyerrok;
           }
           ;

while_stmt:
          WHILE LPAREN bool_exp RPAREN LBRACE stmts RBRACE{
          $$ -> type = 2; // type = 2 for while
          sprintf($$ -> JumpCode, "beq $t0, 1,"); // Branch if the value computed at bool_exp(t0) is 1. Where to, we will decide labels later
          $$ -> while_body = $6;
          $$ -> if_body = NULL;
          $$ -> else_body = NULL;
          }
          ;

if_stmt:
       IF LPAREN bool_exp RPAREN LBRACE stmts RBRACE ELSE LBRACE stmts RBRACE{
       $$ -> type = 1; // type = 1 for if else
       sprintf($$ -> JumpCode, "beqz $t0,"); // Branch to else part
       $$ -> while_body = NULL;
       $$ -> if_body = $6;
       $$ -> else_body = $10;
       }
       ;

// t0 will store the computed value
bool_exp:
        TRUE{
        sprintf($$, "%s", "li $t0, 1\n");
        }
        |
        FALSE{
        sprintf($$, "%s", "li $t0, 0\n");
        }
        ;


// t0 will always have exp
exp:
   x{
   sprintf($$, "%s", $1);
   count ^= 1;
   }
   |
   exp '+' exp{
   $$ = gen_exp($1, $3, 1);
   }
   |
   exp '-' exp{
   $$ = gen_exp($1, $3, 2);
   }
   |
   exp '*' exp{
   $$ = gen_exp($1, $3, 3);
   }
   |
   exp '/' exp{
   $$ = gen_exp($1, $3, 4);
   }
   ;

x:
 NUM{
 sprintf($$, "li $t%d, %d", count, $1);
 count ^= 1;
 }
 |VAR{
 sprintf($$, "lw $t%d, %s($t8)", count, $1->addr);
 count ^= 1;
 }
 ;

%%

void StmtsTrav(stmtsptr ptr){
  printf("stmts\n");
  if(ptr == NULL) return;
  if(ptr -> singl == 1)
    StmtTrav(ptr -> left);
  else{
    StmtTrav(ptr -> left);
    StmtsTrav(ptr -> right);
  }
}

void StmtTrav(stmtptr ptr){
    int ws, nj;
    printf("stmt\n");
    if(ptr == NULL) return;
 
    if(ptr -> type == 0){
        fprintf(fp, "%s\n",ptr -> assgnCode);
    }
    else if(ptr -> type == 1){
        es = elseStart;
        elseStart++;
        nj = End;
        End++;
        fprintf(fp, "%s Else%d\n", ptr->JumpCode, nj);
        StmtsTrav(ptr -> if_body);
        fprintf(fp, "j End%d\nElse%d:\n", nj, es);
        StmtsTrav(ptr -> else_body);
        fprintf(fp, "End%d:\n", nj);
    }
    else if(ptr -> type == 2){
        ws = whileStart;
        whileStart++;
        nj = End;
        End++;
        fprintf(fp, "While%d:\n%s End%d\n", ws, ptr->JumpCode, nj);
        StmtsTrav(ptr -> while_body);
        fprintf(fp, "j While%d\nEnd%d:\n", ws, nj);
    }
}


int main ()
{
   fp=fopen("asmb.asm","w");
   fprintf(fp,".data\n\n.text\nli $t8,268500992\n");
   yyparse ();
   StmtsTrav(final);
   fprintf(fp,"\nli $v0,1\nmove $a0,$t0\nsyscall\n");
   fclose(fp);
}

void yyerror (char *s)  /* Called by yyparse on error */
{
  printf ("%s\n", s);
}


