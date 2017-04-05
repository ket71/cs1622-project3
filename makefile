
all:
	flex mylex.l
	yacc -v grammar.y
	gcc -g -o parser y.tab.c proj2.c -lfl -w