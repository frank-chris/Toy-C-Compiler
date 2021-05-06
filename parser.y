%{

#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "parser.h"  /* Contains definition of `symrec'        */

int whileStart = 0, End = 0, elseStart = 0;
int count = 0;
int labelCount = 0;
FILE *fp;
struct StmtsNode *final;
int  yylex(void);
void yyerror (char  *);
void StmtsTrav(stmtsptr ptr);
void StmtTrav(stmtptr ptr);
%}
%union {
int val;  /* For returning numbers.                   */
int relational_type; /*Type of relational op */
int logical_type; /*Type of logical op */
int arithmetic_type; /* Type of arithmetic op */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
struct exptable  *expptr;   /* For returning expression pointers      */
char nData[200];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}



%token LBRACE RBRACE LPAREN RPAREN
%token TRUE FALSE
%token  WHILE IF ELSE FOR
%token SCAN PRINT
%token SEMICOLON
%token ASSIGN DEFINE
%token AND OR
%token PLUS MINUS TIMES DIVIDE
%token  <val> NUM        /* Integer   */
%token <relational_type> RELATIONAL
%token <logical_type> LOGICAL
%token <arithmetic_type> ARITHMETIC
%token <tptr> VAR   
%type  <expptr>  exp bool_exp x
%type <stmtsptr> stmts
%type <stmtptr> stmt
%type <stmtptr> assign_stmt print_stmt scan_stmt if_stmt while_stmt

%right ASSIGN
%left MINUS PLUS
%left TIMES DIVIDE

// The Grammar

/* Key points / Invariants
1) Every expression has associated with it machine code such that it ensures that the value of the expression is loaded into the register t0.
*/

%%

prog:
    stmts{ 
    final = $1;
     printf("final\n");
    }

stmts: 
     stmt stmts {
     printf("Multiple\n");
     $$ = (struct StmtsNode *)malloc(sizeof(struct StmtsNode));
     $$ -> singl = 0;
     $$ -> left = $1, $$ -> right = $2;
     }
     |
     stmt {
     printf("Single\n");
     $$ = (struct StmtsNode *) malloc(sizeof(struct StmtsNode));
     $$ -> singl = 1;
     $$ -> left = $1, $$ -> right = NULL;
     }
     ;

stmt:
    assign_stmt SEMICOLON{
    $$ = $1;
    }
    |
    scan_stmt SEMICOLON{
    $$ = $1;
    }
    |
    print_stmt SEMICOLON{
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
           VAR ASSIGN exp{
           $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
           $$ -> type = 0; // type = 0 for assignment
           sprintf($$ -> assgnCode, "%s\nsw $t0,%s($t8)\n", $3 -> code, $1 -> addr); // $3 will be t0, its value will be stored at the address(mem location) of the variable.
           $1 -> val  = $3 -> val;
           $$ -> while_body = NULL;
           $$ -> if_body = NULL;
           $$ -> else_body = NULL;
           }
           |
           error{
           yyerrok;
           }
           ;

scan_stmt:
         SCAN LPAREN VAR RPAREN{
         // Don't use the code returned by VAR
         count = 0; // We have to set count back to 0
         $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
         $$ -> type = 4; // type = 4 for scan
         sprintf($$ -> scanCode, "\njal Scan \nsw $t0, %s($t8)", $3 -> addr);
         }

print_stmt:
          PRINT exp{
          $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
          $$ -> type = 3; // type = 3 for print
          sprintf($$ -> printCode, "%s \njal Print \n", $2 -> code);
          }

if_stmt:
       IF LPAREN bool_exp RPAREN LBRACE stmts RBRACE ELSE LBRACE stmts RBRACE{
       $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
       $$ -> type = 1; // type = 1 for if else
       sprintf($$ -> InitCode,"%s", $3 -> code);
       sprintf($$ -> JumpCode, "beqz $t0,"); // Branch to else part
       $$ -> while_body = NULL;
       $$ -> if_body = $6;
       $$ -> else_body = $10;
       }
       ;

while_stmt:
          WHILE LPAREN bool_exp RPAREN LBRACE stmts RBRACE{
          $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
          $$ -> type = 2; // type = 2 for while
          sprintf($$ -> InitCode,"%s", $3 -> code);
          sprintf($$ -> JumpCode, "beqz $t0,"); // Branch if the value computed at bool_exp(t0) is 1. Where to, we will decide labels later
          $$ -> while_body = $6;
          $$ -> if_body = NULL;
          $$ -> else_body = NULL;
          }
          ;

// t0 will store the computed value
// INCOMPLETE
bool_exp:
        TRUE{
        $$ = (exptable *)malloc(sizeof(exptable));
        sprintf($$ -> code, "%s", "li $t0, 1\n");
        }
        |
        FALSE{
        $$ = (exptable *)malloc(sizeof(exptable));
        sprintf($$ -> code, "%s", "li $t0, 0\n");
        }
        |
        LPAREN bool_exp RPAREN{
        $$ = (exptable *)malloc(sizeof(exptable));
        sprintf($$ -> code, "%s", $2 -> code);
        }
        |
        exp RELATIONAL exp{
        $$ = (exptable *)malloc(sizeof(exptable));
        sprintf($$ -> code, "%s", gen_code($1 -> code, $3 -> code, $2));
        $$ -> val  = compute_expr($1 -> val, $3 -> val, $2);
        }
        |
        bool_exp LOGICAL bool_exp{
        $$ = (exptable *)malloc(sizeof(exptable));
        sprintf($$ -> code, "%s", gen_code($1 -> code, $3 -> code, $2));
        $$ -> val  = compute_expr($1 -> val, $3 -> val, $2);
        }
        ;


// t0 will always have exp
exp:
   x{
   $$ = (exptable *)malloc(sizeof(exptable));
   sprintf($$ -> code, "%s", $1 -> code);
   $$ -> val = $1 -> val;
   count ^= 1;
   }
   |
   LPAREN exp RPAREN{
   $$ = (exptable *)malloc(sizeof(exptable));
   sprintf($$ -> code, "%s", $2 -> code);
   $$ -> val = $2 -> val;
   }
   |
   exp ARITHMETIC exp{
   $$ = (exptable *)malloc(sizeof(exptable));
   sprintf($$ -> code, "%s", gen_code($1 -> code, $3 -> code, $2));
   $$ -> val  = compute_expr($1 -> val, $3 -> val, $2);
   }
   ;

x:
 NUM{
 $$ = (exptable *)malloc(sizeof(exptable));
 sprintf($$ -> code, "li $t%d, %d", count, $1);
 $$ -> val = $1;
 count ^= 1;
 }
 |
 VAR{
 $$ = (exptable *)malloc(sizeof(exptable));
 sprintf($$ -> code, "lw $t%d, %s($t8)", count, $1 -> addr);
 $$ -> val = $1 -> val;
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
    int ws, nj, es;
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
        fprintf(fp, "%s \n", ptr->InitCode);
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
        fprintf(fp, "While%d:\n", ws);
        fprintf(fp, "%s \n", ptr->InitCode);
        fprintf(fp, "%s End%d\n", ptr->JumpCode, nj);
        StmtsTrav(ptr -> while_body);
        fprintf(fp, "j While%d\nEnd%d:\n", ws, nj);
    }
    else if(ptr -> type == 3){
        fprintf(fp, "%s\n",ptr -> printCode);
    }
    else if(ptr -> type == 4){
        fprintf(fp, "%s\n",ptr -> scanCode);
    }
}


int main ()
{
    Adr = 0;
    sym_table = (symrec *)0;
    fp=fopen("asmb.asm","w");
    fprintf(fp, ".data\n\n.text\nli $t8,268500992\n");
    fprintf(fp, "\nj PrintEnd \nPrint: \nli $v0, 1 \nmove $a0, $t0 \nsyscall \njr $ra \nPrintEnd: \n");
    fprintf(fp, "\nj ScanEnd \nScan: \nli $v0, 5 \nsyscall \nmove $t0, $v0 \njr $ra \nScanEnd: \n");
    yyparse ();
    StmtsTrav(final);
    fprintf(fp,"\nli $v0,10\nsyscall\n");
    fclose(fp);
}

void yyerror (char *s)  /* Called by yyparse on error */
{
  printf ("%s\n", s);
}

