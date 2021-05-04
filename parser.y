%{

#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "parser.h"  /* Contains definition of `symrec'        */

int Adr=0;
symrec *sym_table = (symrec *)0;
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
int relop_type; /*Type of relop */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
char c[1000];
char nData[100];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}



%token LBRACE RBRACE LPAREN RPAREN
%token TRUE FALSE
%token  WHILE IF ELSE FOR
%token SEMICOLON
%token ASSIGN DEFINE
%token AND OR
%token PLUS MINUS TIMES DIVIDE
%token  <val> NUM        /* Integer   */
%token <val> RELOP
%token <tptr> VAR   
%type  <c>  exp
%type  <c>  bool_exp
%type <nData> x
%type <stmtsptr> stmts
%type <stmtptr> stmt
%type <stmtptr> assign_stmt if_stmt while_stmt

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
    //printf("%s\n", final -> left -> assgnCode);
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
          $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
          $$ -> type = 2; // type = 2 for while
          sprintf($$ -> JumpCode, "beq $t0, 1,"); // Branch if the value computed at bool_exp(t0) is 1. Where to, we will decide labels later
          $$ -> while_body = $6;
          $$ -> if_body = NULL;
          $$ -> else_body = NULL;
          }
          ;

if_stmt:
       IF LPAREN bool_exp RPAREN LBRACE stmts RBRACE ELSE LBRACE stmts RBRACE{
       $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
       $$ -> type = 1; // type = 1 for if else
       sprintf($$ -> JumpCode, "beqz $t0,"); // Branch to else part
       $$ -> while_body = NULL;
       $$ -> if_body = $6;
       $$ -> else_body = $10;
       }
       ;

// t0 will store the computed value
// INCOMPLETE
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
   LPAREN exp RPAREN{
   sprintf($$, "%s", $2);
   }
   |
   exp PLUS exp{
   sprintf($$, "%s", gen_code($1, $3, 1));
   }
   |
   exp MINUS exp{
   sprintf($$, "%s", gen_code($1, $3, 2));
   }
   |
   exp TIMES exp{
   sprintf($$, "%s", gen_code($1, $3, 3));
   }
   |
   exp DIVIDE exp{
   sprintf($$, "%s", gen_code($1, $3, 4));
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

char *gen_code(char *code1, char *code2, int opt){

    // The correct operation instruction
    char *op_code = (char *)malloc(4 * sizeof(char));
    switch(opt){
        case 1:
            //op_code = "add";
            op_code = strdup("add");
            break;
        case 2:
            //op_code = "sub";
            op_code = strdup("sub");
            break;
        case 3:
            //op_code = "mul";
            op_code = strdup("mul");
            break;
        case 4:
            //op_code = "div";
            op_code = strdup("div");
            break;
    }

    printf("%s\n", op_code);
    int l1 = strlen(code1);
    int l2 = strlen(code2);
    char *code = (char *)malloc(2000 * sizeof(char)); // We can calculate this

    sprintf(code, "%s\n", code1); // All instructions to load the first expression into t0

    // Now store the value in t0 into the stack

    // Decrement the stack pointer by 4
    sprintf(code, "%s %s\n", code, "subu $sp, $sp, 4");
    // Store t0 here
    sprintf(code, "%s %s\n", code, "sw $t0 4($sp)");

    sprintf(code, "%s %s\n", code, code2); // All instructions to load the second expression into t0

    // Repeat steps
    sprintf(code, "%s %s\n", code, "subu $sp, $sp, 4");
    sprintf(code, "%s %s\n", code, "sw $t0 4($sp)");

    // Load expression2 into t1 and expression1 into t0
    sprintf(code, "%s %s\n", code, "lw $t1 4($sp)");
    sprintf(code, "%s %s\n", code, "addi $sp, $sp, 4");
    sprintf(code, "%s %s\n", code, "lw $t0 4($sp)");
    sprintf(code, "%s %s\n", code, "addi $sp, $sp, 4");

    // Finally, store result into t0
    sprintf(code, "%s %s %s\n", code, op_code, "$t0, $t0, $t1");

    return code;
}

symrec * putsym (char *sym_name,int sym_type){
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  sprintf(ptr->addr,"%d",Adr); /* set value to 0 even if fctn.  */
  Adr=Adr+4;
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym (char *sym_name){
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}

