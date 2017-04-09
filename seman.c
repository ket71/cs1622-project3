#include "proj2.h"
#include "proj3.h"
#include <stdio.h>
#include <string.h>

#define LIMIT1 500

extern FILE* treelst;
extern symbolTable[LIMIT1 + 1];
extern tree root;
extern int error;

int loc_srt(char search[]);
void traverse();
void traverse_recursive(tree root);


void traverse(){
	traverse_recursive(root);
}

void traverse_recursive(tree root){
	if(IsNull(root)){
		printf("null");
		return;
	}
}

int main(int argc, char* argv){
	treelst = stdout;
	yyparse();
} 


/*	Implements loc_str function found in proj3.c	*/
int loc_str(char search[]){
	int i = 0;
	char word[LIMIT1+1];
	symbolTable[LIMIT1] = '\0';
	while (i < LIMIT1) {
		strcpy(&word[0], &(symbolTable[i]));
		if (!strcasecmp(word, search)) {
			return i;
		}
		else {
			i = i + strlen(word);
		}
		i++;
	}
	return -1;
}
