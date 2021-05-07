#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"

symrec *putsym(char *sym_name){
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof (symrec));
  ptr -> name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr -> name, sym_name);
  sprintf(ptr->addr, "%d", Adr); /* set value to 0 even if fctn.  */
  Adr = Adr + 4;
  ptr -> next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym(char *sym_name){
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
       if (strcmp (ptr->name,sym_name) == 0)
           return ptr;
  return 0;
}

void arr_allocate(symrec *tptr, int size){
    Adr += (size - 1);


    // In case we want to store the values stored by arrays
    /*
    printf("Size: %d\n", size);
    //printf("Size of tptr: %ld\n", sizeof(tptr));
    for(int i = 0; i < size - 1; i++){
        symrec *ptr;
        ptr = (symrec *) malloc (sizeof (symrec));
        ptr -> name = (char *) malloc (strlen (tptr -> name) + 1);
        ptr -> val = i + 1;
        strcpy (ptr -> name, tptr -> name);
        sprintf(ptr -> addr, "%d", Adr); // set value to 0 even if fctn.
        Adr = Adr + 4;
        ptr->next = (struct symrec *)sym_table;
        sym_table = ptr;
    }
*/

}
