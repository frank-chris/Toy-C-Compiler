#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include "parser.tab.h"
#include <string.h>

char *gen_code(char *code1, char *code2, int opt){

    // The correct operation instruction
    char *op_code = (char *)malloc(4 * sizeof(char));
    switch(opt){
        case 1:
            op_code = "slt";
            break;
        case 2:
            op_code = "sgt";
            break;
        case 3:
            op_code = "sle";
            break;
        case 4:
            op_code = "sge";
            break;
        case 5:
            op_code = "seq";
            break;
        case 6:
            op_code = "sne";
            break;
        case 7:
            op_code = "and";
            break;
        case 8:
            op_code = "or";
            break;
        case 9:
            op_code = "xor";
            break;
        case 10:
            op_code = "add";
            break;
        case 11:
            op_code = "sub";
            break;
        case 12:
            op_code = "mul";
            break;
        case 13:
            op_code = "div";
            break;
        case 14:
            op_code = "rem";
            break;
    }

    printf("%s\n", op_code);
    int l1 = strlen(code1);
    int l2 = strlen(code2);
    char *code = (char *)malloc(2000 * sizeof(char)); // We can calculate this

    sprintf(code, "%s\n", code1); // All instructions to load the first expression into t0

    // Now store the value in t0 into the stack

    // Decrement the stack pointer by 4
    sprintf(code, "%s%s\n", code, "subu $sp, $sp, 4");
    // Store t0 here
    sprintf(code, "%s%s\n", code, "sw $t0 ($sp)");

    sprintf(code, "%s%s\n", code, "addi $sp, $sp, 4");
    sprintf(code, "%s%s\n", code, code2); // All instructions to load the second expression into t0
    sprintf(code, "%s%s\n", code, "subu $sp, $sp, 4");

    // Repeat steps
    sprintf(code, "%s%s\n", code, "subu $sp, $sp, 4");
    sprintf(code, "%s%s\n", code, "sw $t0 ($sp)");

    // Load expression2 into t1 and expression1 into t0
    sprintf(code, "%s%s\n", code, "lw $t1 ($sp)");
    sprintf(code, "%s%s\n", code, "addi $sp, $sp, 4");
    sprintf(code, "%s%s\n", code, "lw $t0 ($sp)");
    sprintf(code, "%s%s\n", code, "addi $sp, $sp, 4");

    // Finally, store result into t0
    sprintf(code, "%s%s %s\n", code, op_code, "$t0, $t0, $t1");

    return code;
}


int compute_expr(int exp1, int exp2, int opt){

    int ans; // stores the result of the expression
    switch(opt){
        case 1:
            ans = (exp1 < exp2);
            break;
        case 2:
            ans = (exp1 > exp2);
            break;
        case 3:
            ans = (exp1 <= exp2);
            break;
        case 4:
            ans = (exp1 >= exp2);
            break;
        case 5:
            ans = (exp1 == exp2);
            break;
        case 6:
            ans = (exp1 != exp2);
            break;
        case 7:
            ans = (exp1 & exp2); // & returns bitwise and, use && if bool answer required
            break;
        case 8:
            ans = (exp1 | exp2);
            break;
        case 9:
            ans = (exp1 ^ exp2);
            break;
        case 10:
            ans = (exp1 + exp2);
            break;
        case 11:
            ans = (exp1 - exp2);
            break;
        case 12:
            ans = (exp1 * exp2);
            break;
        case 13:
            ans = (exp1 / exp2);
            break;
        case 14:
            ans = (exp1 % exp2);
            break;
    }

    return ans;
}

