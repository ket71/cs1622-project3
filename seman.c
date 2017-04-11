#include "proj2.h"
#include "proj3.h"
#include <stdio.h>
#include <string.h>

#define LIMIT1 500

extern FILE* treelst;
extern symbolTable[LIMIT1 + 1];
extern tree root;
extern int error;

int loc_str(char search[]);
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

/* Process left recursive*/
void leftRec(tree root){
	if(IsNull(root)){
		return;
	}
	analyze(root);
	leftRec(LeftChild(root)); //order can be wrong
}

/* Process right recursive*/
void rightRec(tree root){
	if(IsNull(root)){
		return;
	}
	analyze(root);
	rightRec(RightChild(root)); //order can be wrong
}

/*	Calls different functions based on root node kind/op	*/
void analyze(tree root){
	if(NodeKind(root) == STRINGNode){

	}else{
		if(NodeOp(root) == ClassOp){
			classOp(root);

		}else if(NodeOp(root) == BodyOp){
			bodyOp(root);
		}else if(NodeOp(root) == DeclOp){
			declOp(root);
		}else if(NodeOp(root) == BoundOp){
			//expression(root);
			
		}else if(NodeOp(root) == CommaOp){
			//expression(root);
			
		}else if(NodeOp(root) == StmtOp){
			//statement(root);
		}else if(NodeOp(root) == RArgTypeOp || NodeOp(root) == VArgTypeOp){
			//argument(root);
		}
	}
}

void classOp (tree root){
	tree node = RightChild(root);
	//if ClassDefOp node is not a leaf
	if(NodeKind(node) == EXPRNode){
		tree class = RightChild(node);
		if(NodeKind(class) == EXPRNode)
			return;
		int nSymInd = InsertEntry(IntVal(class));
		SetAttr(nSymInd, KIND_ATTR, CLASS);
		//STNode ???
		//intVal to nSymInd ???
		OpenBlock();
		traverse(node);
		CloseBlock();
	}
	
}

void bodyOp (tree root){
	tree node = RightChild(root);
	if(NodeKind(node) == EXPRNode){
		if(NodeOp(node) == DeclOp){
			leftRec(root);
		}else if(NodeOp(node) == MethodOp){
			//method(node);
		}else if (NodeOp(node) == StmtOp){
			traverse(node);
		}
	}else{
		if(NodeKind(root) == STRINGNode){
			error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
		}
	}
}

void methodOp(tree root){
	tree left = LeftChild(root);
	tree name = LeftChild(left);
	int nSymInd = InsertEntry(IntVal(name));
	//set node kind and int val?
	tree type = RightChild(RightChild(left));
	if(IsNull(type)){
		SetAttr(nSymInd, KIND_ATTR, PROCE);
	}else{
		SetAttr(nSymInd, KIND_ATTR, FUNC);
		SetAttr(nSymInd, TYPE_ATTR, type);
	}
	OpenBlock();
	//keep track of number of args?
	rightRec(LeftChild(RightChild(left)));
	traverse(RightChild(root));
	CloseBlock();
	
}

void declOp(tree root){
	tree right = RightChild(root);
	tree varName = LeftChild(right);
	int nSymInd = InsertEntry(IntVal(varName));
	SetAttr(nSymInd, KIND_ATTR, VAR);
	tree type = LeftChild(RightChild(right));
	SetAttr(nSymInd, TYPE_ATTR, type);
	//varInt(); varInt, nSymInd
	//STNode ???
		//intVal to nSymInd ???
	//type
	//array
}

void varInt(tree root, int nSymInd){
	if(IsNull(root)){
		return;
	}
	if(NodeKind(root) == EXPRNode){
		if(NodeOp(root) != ArrayTypeOp){
			//exp(root, nSymInd);
		}else{
			//array(root, nSymInd);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

int main(int argc, char* argv){
	treelst = stdout;
	yyparse();

	STInit();
	traverse();
	STPrint();
	
} 
