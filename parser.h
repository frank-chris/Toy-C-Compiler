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

symrec *putsym ();
symrec *getsym ();

typedef struct StmtsNode *stmtsptr;
typedef struct StmtNode *stmtptr;


 struct StmtsNode{
   int singl;
   struct StmtNode *left;
   struct StmtsNode *right;
 };



struct StmtNode{
   int isWhile;
   char initCode[100];
   char initJumpCode[20];
   char bodyCode[1000]; // assgnCode[1000];
   struct StmtsNode *down;
};




/*void StmtsTrav(stmtsptr ptr);
  void StmtTrav(stmtptr *ptr);*/
