#ifndef PARSER_H
#define PARSER_H

/* Data type for links in the chain of symbols.      */
struct symrec
{
  char *name;  /* name of symbol                     */
  char addr[100];           /* value of a VAR          */
  struct symrec *next;    /* link field              */
};

typedef struct symrec symrec;



/* The symbol table: a chain of `struct symrec'.     */

int Adr;
symrec *sym_table;


symrec *putsym ();
symrec *getsym ();
char *gen_code(char *code1, char *code2, int opt);
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
   char assgnCode[1000];
   struct StmtsNode *while_body;
   struct StmtsNode *if_body;
   struct StmtsNode *else_body;
};




/*void StmtsTrav(stmtsptr ptr);
  void StmtTrav(stmtptr *ptr);*/

#endif /* PARSER_H */
