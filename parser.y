%{

#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "parser.h"  /* Contains definition of `symrec'        */

int whileStart = 0, End = 0, elseStart = 0;
int count = 0;
symrec *sptr;
symrec *cur_table;
funcrec *fptr;
int func = 0;
int labelCount = 0;
FILE *fp;
struct StmtsNode *final;
int  yylex(void);
void yyerror (char  *);
void StmtsTrav(stmtsptr ptr);
void StmtTrav(stmtptr ptr);
%}
%union {
int val;  /* For returning numbers. */
int relational_type; /*Type of relational op */
int logical_type; /*Type of logical op */
int arithmetic_type; /* Type of arithmetic op */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
struct exptable  *expptr;   /* For returning expression pointers      */
char var[200];
char Code[1000];
char smallCode[100];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}



%token LBRACE RBRACE LPAREN RPAREN LBRACK RBRACK
%token TRUE FALSE
%token  WHILE IF ELSE FOR
%token SCAN PRINT
%token SEMICOLON COMMA
%token ASSIGN DEFINE
%token AND OR
%token PLUS MINUS TIMES DIVIDE
%token  <val> NUM        /* Integer   */
%token <relational_type> RELATIONAL
%token <logical_type> LOGICAL
%token <arithmetic_type> ARITHMETIC
%token <var> VAR
%type <Code> local_variable_decl 
%type <smallCode> local_decl 
%type  <expptr>  exp bool_exp x
%type <stmtsptr> stmts 
%type <stmtptr> stmt
%type <stmtptr> function_decl array_decl assign_stmt print_stmt scan_stmt if_stmt while_stmt

%right ASSIGN
%left MINUS PLUS
%left TIMES DIVIDE MODULUS

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
    function_decl{
    $$ = $1;
    }
    |
    array_decl SEMICOLON{
    $$ = $1;
    }
    |
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

/*
From top to bottom, a function will store-
1) Base address of caller
2) Return address
3) Parameters
4) Local variables
Store the current base address and the return value in registers
*/
function_decl:
        VAR{
        fptr = (funcrec *)malloc(sizeof(funcrec));
        fptr -> name = $1;
        func = 1;
        }
        LPAREN{
        fptr -> f_symrec = (symrec *)malloc(sizeof(symrec));
        fptr -> params = 0;
        }
        parameter_list RPAREN LBRACE{
        fptr -> local_vars = 0;
        }
        local_variable_decl{
        sym_table = cur_table;
        cur_table = fptr -> f_symrec;
        }
        stmts RBRACE{
        cur_table = sym_table;

        putfunc(fptr);

        $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
        $$ -> type = 3; // type = 3 for function
        sprintf($$ -> funCode, "%s", $9);
        $$ -> func_body = $11;

        func = 0;
        }
        ;

parameter_list:
              |
              VAR COMMA parameter_list{
              putsym($1, fptr -> f_symrec, 1, (fptr -> params + 1) * 4);
              fptr -> params += 1;
              }
              |
              VAR{
              putsym($1, fptr -> f_symrec, 1, (fptr -> params + 1) * 4);
              fptr -> params += 1;
              }
              ;

local_variable_decl:
                   local_decl local_variable_decl {
                   strcat($$, $1);
                   strcat($$, $2);
                   }
                   |
                   local_decl{
                   strcat($$, $1);
                   }
                   |
                   {
                   sprintf($$, "%s", "");
                   }
                   ;

local_decl:
          VAR ASSIGN NUM SEMICOLON{
          putsym($1, fptr -> f_symrec, 1, (fptr -> params + fptr -> local_vars + 1) * 4);
          fptr -> local_vars += 1;
          sprintf($$, "subu $sp, $sp, 4\nli $t0, %d\nsw $t0, ($sp)\n", $3);
          }
          ;


array_decl:
          VAR LBRACK exp RBRACK{
          $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
          $$ -> type = 0; // type = 0 for declaration and assignment
          
          sptr = getsym($1, cur_table);
          if(sptr == 0)
              sptr = putsym($1, cur_table, 0, 0);
          // Allocate space equal to size of exp
          arr_allocate(sptr, $3 -> val);
          sptr -> len = $3 -> val;
          }
          ;

    
assign_stmt:
           VAR ASSIGN exp{
           $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
           $$ -> type = 0; // type = 0 for declaration and assignment
           sptr = getsym($1, cur_table);
           if(sptr == 0){
               sptr = putsym($1, cur_table, 0, 0);
           }
 printf("Name: %s\n", $1);
 fflush(stdout);
           sprintf($$ -> assgnCode, "%s\nsw $t0,%s($t8)\n", $3 -> code, sptr -> addr); // $3 will be t0, its value will be stored at the address(mem location) of the variable.
           sptr -> val  = $3 -> val;
           cur_table = sptr;
           $$ -> while_body = NULL;
           $$ -> if_body = NULL;
           $$ -> else_body = NULL;
           }
           |
           VAR LBRACK exp RBRACK ASSIGN exp{
           $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
           $$ -> type = 0; // type = 0 for declaration and assignment
           sptr = getsym($1, cur_table);
           sprintf($$ -> assgnCode, "%s\n", $3 -> code);
           sprintf($$ -> assgnCode, "%ssll $t0, $t0, 2\n", $$ -> assgnCode); // Multiply by 4
           sprintf($$ -> assgnCode, "%sadd $t0, $t0, $t8\n", $$ -> assgnCode); // Add the global base into $t0
           sprintf($$ -> assgnCode, "%sadd $t0, $t0, %s\n", $$ -> assgnCode, sptr -> addr); // Add the base address of VAR into $t2

           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, "subu $sp, $sp, 4");
           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, "sw $t0 4($sp)"); // Store calculated address into the stack

           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, $6 -> code);

           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, "lw $t1 4($sp)");
           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, "addi $sp, $sp, 4");

           sprintf($$ -> assgnCode, "%s%s\n", $$ -> assgnCode, "sw $t0, ($t1)\n");
           }
           |
           error{
           yyerrok;
           }
           ;

scan_stmt:
         SCAN LPAREN VAR RPAREN{
         // Don't use the code returned by VAR
         $$ = (struct StmtNode *) malloc(sizeof(struct StmtNode));
         $$ -> type = 4; // type = 4 for scan
         sptr = getsym($3, cur_table);
         sprintf($$ -> scanCode, "\njal Scan \nsw $t0, %s($t8)", sptr -> addr);
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
 sprintf($$ -> code, "li $t0, %d\n", $1);
 $$ -> val = $1;
 }
 |
 VAR LBRACK exp RBRACK{
 // There are two ways of doing this
 $$ = (exptable *)malloc(sizeof(exptable));
 sptr = getsym($1, cur_table);
 if(func == 0){
     sprintf($$ -> code, "%s\nsll $t0, $t0, 2\nadd $t0, $t0, $t8\nadd $t0, $t0, %s\nlw $t0, ($t0)\n", $3 -> code, sptr -> addr);
 }
 else{
     printf("Arrays  in functions\n");
 }

 $$ -> val = -1;
 }
 |
 VAR{
   printf("HEYY%s\n", cur_table -> addr);
   fflush(stdout);
 $$ = (exptable *)malloc(sizeof(exptable));
 sptr = getsym($1, cur_table);
 if(sptr == 0){
     printf("Variable not declared.\n");
     fflush(stdout);
 }
 if(func == 0){
     sprintf($$ -> code, "lw $t0, %s($t8)\n", sptr -> addr);
 }
 else{
     int tot_vars = fptr -> params + fptr -> local_vars;
     int faddr = (tot_vars * 4) - atoi(sptr -> addr);
     sprintf($$ -> code, "lw $t0, %d($sp)\n", faddr);
 }
 $$ -> val = sptr -> val;
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


int main()
{
    Adr = 0;
    sym_table = (symrec *)0;
    cur_table = sym_table;
    func_table = (funcrec *)0;
    fp=fopen("asmb.asm","w");
    fprintf(fp, ".data\n\n.text\nli $t8,268500992\n");
    fprintf(fp, "\nj PrintEnd \nPrint: \nli $v0, 1 \nmove $a0, $t0 \nsyscall \nli $v0, 11 \nla $a0, '\\n' \nsyscall \njr $ra \nPrintEnd: \n");
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

