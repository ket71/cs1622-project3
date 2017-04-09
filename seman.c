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


/*	Starts recursive call to traverse whole tree 	*/
void traverse(){
	traverse_recursive(root);
}


/*	Recursively iterates through whole tree 	*/
void traverse_recursive(tree root){
	if(IsNull(root)){
		return;
	}else{
		traverse_recursive(LeftChild(root));
		analyze(root);
	}
}


/*	Calls different functions based on root node kind/op	*/
void analyze(tree root){
	if(NodeKind(root) == STRINGNode){

	}else{
		if(NodeOp(root) == ClassOp){

		}else if(NodeOp(root) == BodyOp){

		}else if(NodeOp(root) == DeclOp){
			
		}else if(NodeOp(root) == BoundOp){
			
		}else if(NodeOp(root) == CommaOp){
			
		}else if(NodeOp(root) == StmtOp){
			
		}else if(NodeOp(root) == RArgTypeOp || NodeOp(root) == VArgTypeOp){
			
		}
	}
}


int main(int argc, char* argv){
	treelst = stdout;
	yyparse();

	STInit();
	traverse();
	STPrint();
	
} 
