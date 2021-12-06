all:
	bison -d --debug --output-file=parse.c parse.y
	gcc -g -Wall -Wextra -pipe -pedantic -std=c99 -g -c -o parse.o parse.c
	flex -d --header-file --yylineno --outfile=scanner.c scanner.l
	gcc -g -Wall -Wextra -pipe -pedantic -std=c99 -g -c -o scanner.o scanner.c
	gcc -g -o main parse.o scanner.o  -lfl

clean:
	rm parse.c parse.o scanner.c scanner.o main parse.h
