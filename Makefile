build: flex bison obj
	@echo "Building"
	gcc -lfl parser.tab.o expressions.o func_operations.o sym_operations.o lex.yy.o -o C

flex: lexer.l
	@echo "Building Lexer..."
	flex lexer.l

bison: parser.y
	@echo "Building Parser..."
	bison -d parser.y

obj: expressions.c sym_operations.c parser.tab.c lex.yy.c
	@echo "Compiling support files ..."
	gcc -c expressions.c sym_operations.c func_operations.c parser.tab.c lex.yy.c

clean:
	@echo "Cleaning..."
	@rm -rvf lex.yy.c parser.tab.h parser.tab.c expressions.o sym_operations.o func_operations.o parser.tab.o lex.yy.o
