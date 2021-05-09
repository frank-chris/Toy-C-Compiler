#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"

void putfunc(funcrec *ptr){
  ptr -> next = (struct funcrec *)func_table;
  func_table = ptr;
}


funcrec *getfunc(char *func_name){
  funcrec *ptr;
  for (ptr = func_table; ptr != (funcrec *) 0; ptr = (funcrec *)ptr -> next)
       if (strcmp (ptr -> name, func_name) == 0)
           return ptr;
  return 0;
}
