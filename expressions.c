#include <stdio.h>
#include <stdlib.h>
#include "parser.h"

char *gen_code(char *code1, char *code2, int opt){

    // The correct operation instruction
    char *op_code = (char *)malloc*(4 * sizeof(char));
    switch(opt){
        case 1:
            op_code = "add";
            break;
        case 2:
            op_code = "sub";
            break;
        case 3:
            op_code = "mul";
            break;
        case 4:
            op_code = "div";
            break;
    }

    int l1 = strlen(code1);
    int l2 = strlen(code2);
    char *code = (char *)malloc(200); // We can calculate this

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
