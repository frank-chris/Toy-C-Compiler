/* Data type for links in the chain of symbols.      */
struct symrec
{
  char *name;  /* name of symbol                     */
  char addr[100];           /* value of a VAR          */
  struct symrec *next;    /* link field              */
};

typedef struct symrec symrec;



/* The symbol table: a chain of `struct symrec'.     */
extern symrec *sym_table;

int  yylex(void);
void yyerror (char  *);
symrec *putsym ();
symrec *getsym ();
char *gen_code(char *exp1, char *exp2, int opt);

typedef struct StmtsNode *stmtsptr;
typedef struct StmtNode *stmtptr;


 struct StmtsNode{
   int singl;
   struct StmtNode *left;
   struct StmtsNode *right;
 };



int whileStart = 0, End = 0, elseStart = 0;
struct StmtNode{
   int type;
   char JumpCode[20];
   char assgnCode[1000];
   struct StmtsNode *while_body;
   struct StmtsNode *if_body;
   struct StmtsNode *else_body;
};




/*void StmtsTrav(stmtsptr ptr);
  void StmtTrav(stmtptr *ptr);*/
