#ifndef PARSER_H
#define PARSER_H

/* Data type for links in the chain of symbols.      */
struct symrec
{
  char *name;  /* name of symbol                     */
  char addr[100];           /* value of a VAR          */
  int val; /* value of the VAR */
  struct symrec *next;    /* link field              */
  int len; /* Length of array. -1 if just a variable. */
  int pos; /* position of parameter */
};

struct funcrec{
    char *name; /* name of the function */
    int params; /* number of parameters */
    int local_vars; /* number of local variables */
    int fnum;
    struct symrec *f_symrec; /* each function has its own symbol table */
    struct funcrec *next; /* next(technically previous) function definition */
};

struct exptable{
    char code[2000];
    int val;
};


typedef struct symrec symrec;
typedef struct exptable exptable;
typedef struct funcrec funcrec;



/* The symbol table: a chain of `struct symrec'.     */

int Adr;
symrec *sym_table;
funcrec *func_table;
int func;


symrec *putsym();
symrec *getsym();
funcrec *putfunc();
funcrec *getfunc();

void arr_allocate(symrec *tptr, int size);
char *gen_code(char *code1, char *code2, int opt);
int compute_expr(int exp1, int exp2, int opt);
int  yylex(void);
void yyerror (char  *);

typedef struct StmtsNode *stmtsptr;
typedef struct StmtNode *stmtptr;


 struct StmtsNode{
   int singl;
   struct StmtNode *left;
   struct StmtsNode *right;
 };



struct StmtNode{
   int type;
   char InitCode[1000];
   char JumpCode[2000];
   char ReturnCode[1000];
   char assgnCode[1000];
   char printCode[1000];
   char scanCode[1000];
   char funCode[1000];
   char forStart[1000];
   char forEnd[1000];
   char simpleCode[1000];
   struct StmtsNode *while_body;
   struct StmtsNode *if_body;
   struct StmtsNode *else_body;
   struct StmtsNode *func_body;
};



/*void StmtsTrav(stmtsptr ptr);
  void StmtTrav(stmtptr *ptr);*/

#endif /* PARSER_H */
