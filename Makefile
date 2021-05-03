a.out: parser.tab.o lex.yy.o
	cc -g parser.tab.o lex.yy.o -lfl

parser.tab.o: parser.tab.h parser.tab.c
	cc -g -c parser.tab.c

lex.yy.o: parser.tab.h lex.yy.c
	cc -g -c lex.yy.c

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.h: parser.y
	bison -d parser.y

clean:
	rm parser.tab.c parser.tab.o lex.yy.o a.out parser.tab.h lex.yy.c
