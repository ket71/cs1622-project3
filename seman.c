/*
Problems:

-main is currently not inserted into the symbol table

-undeclared symbol error needs to be implemented

-array kinds are being labeled as variables

-need to fix error messages

-need to implement dimension error

-need to implement argnum

-parameter variables are not working (Ex4)

-need to handle redeclaration (Ex5) //Still Seg Faults
*/
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
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}else{
		if(NodeOp(root) == ClassOp){
			classOp(root);
		}else if(NodeOp(root) == BodyOp){
			bodyOp(root);
		}else if(NodeOp(root) == DeclOp){
			declOp(root);
		}else if(NodeOp(root) == BoundOp){
			expression(RightChild(root));
		}else if(NodeOp(root) == CommaOp){
			expression(LeftChild(root));
		}else if(NodeOp(root) == StmtOp){
			statement(root);
		}else if(NodeOp(root) == RArgTypeOp || NodeOp(root) == VArgTypeOp){
			argument(root);
		}
	}
}

// analyze classOp
void classOp (tree root){
	tree node = RightChild(root);
	//if node is not a leaf
	if(NodeKind(node) == EXPRNode){
		if(NodeOp(node) == ClassDefOp){
			tree class = RightChild(node);
			if(NodeKind(class) == EXPRNode)
				return;
			// Insert class
			int nSymInd = InsertEntry(IntVal(class));
			SetAttr(nSymInd, KIND_ATTR, CLASS);
			/*
			setNodeKind(class, STNode);
			setIntVal(class, nSymInd);
			*/
			
			OpenBlock();
			traverse_recursive(node);
			CloseBlock();
		}
	}
	
}

//analyze bodyOp
void bodyOp (tree root){
	tree node = RightChild(root);
	//if node is not leaf
	if(NodeKind(node) == EXPRNode){
		if(NodeOp(node) == DeclOp){
			leftRec(node);
		}else if(NodeOp(node) == MethodOp){
			methodOp(node);
		}else if (NodeOp(node) == StmtOp){
			traverse_recursive(node);
		}
	}else{
		if(NodeKind(root) == STRINGNode){
			error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
		}
	}
}

//analyze statement
void statement(tree root){
	tree right = RightChild(root);
	//if node is null
	if(IsNull(right))
		return;
	//if node is not leaf
	if(NodeKind(right) == EXPRNode){
		if(NodeOp(right) == AssignOp){
			assignOp(right);
		}else if(NodeOp(right) == LoopOp){
			loopOp(right);
		}else if(NodeOp(right) == IfElseOp){
			ifElseOp(right);
		}else if(NodeOp(right) == RoutineCallOp){
			routineCallOp(right);
		}else if(NodeOp(right) == ReturnOp){
			returnOp(right);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

//analyze method
void methodOp(tree root){
	tree left = LeftChild(root);
	//get method name
	tree name = LeftChild(left);
	int nSymInd = InsertEntry(IntVal(name));
	if(nSymInd == -1)
		return;
	/*
	setNodeKind(name, STNode);
	setIntVal(name, nSymInd);
	*/
	tree type = RightChild(RightChild(left));
	if(IsNull(type)){
		SetAttr(nSymInd, KIND_ATTR, PROCE);
	}else{
		SetAttr(nSymInd, KIND_ATTR, FUNC);
		SetAttr(nSymInd, TYPE_ATTR, type); /* (uintptr_t) */
	}
	OpenBlock();
	//keep track of number of args? count args function?
	rightRec(LeftChild(RightChild(left)));
	traverse_recursive(RightChild(root));
	CloseBlock();
	
}

//analyze declOp
void declOp(tree root){
	tree right = RightChild(root);
	//variable name
	tree varName = LeftChild(right);
	//insert variable into symbolTable
	int nSymInd = InsertEntry(IntVal(varName));
	if(nSymInd == 0)
		return;
	//variable attributes
	SetAttr(nSymInd, KIND_ATTR, VAR);
	/*
	setNodeKind(name, STNode);
	setIntVal(name, nSymInd);
	*/
	//variable type
	tree type = LeftChild(RightChild(right));
	SetAttr(nSymInd, TYPE_ATTR, type); /* uintptr_t */
	/*
	if(NodeKind(type) == IDNode){
		int typeIndex = IntVal(type);
		int typeSymInd = LookUp(typeIndex);
		setNodeKind(type, STNode);
		setIntVal(type, typeSymInd);
	}
	*/
	// Count dimensions function
	// for array
	tree variableInt = RightChild(RightChild(right));
	varInt(variableInt, nSymInd);
}

//variable initialization
void varInt(tree root, int nSymInd){
	if(IsNull(root)){
		return;
	}
	if(NodeKind(root) == EXPRNode){
		if(NodeOp(root) == ArrayTypeOp){
			array(root, nSymInd); // add dimension parameter?
			
		}else{
			expression(root);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

void expression(tree root){
	if(IsNull(root))
		return;
	if(NodeKind(root) == EXPRNode){ //possibly add empty if statements for other compare ops
		if(NodeOp(root) == GTOp){
			simpleExpression(LeftChild(root));
			simpleExpression(RightChild(root));
		}else{
			simpleExpression(root);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

void simpleExpression(tree root){
	if(IsNull(root))
		return;
	if(NodeKind(root) == EXPRNode){ //possibly add empty if statements for addops and sub ops
		if(NodeOp(root) == UnaryNegOp){
			term(LeftChild(root));
		}else if(NodeKind(root) == OrOp){
			simpleExpression(LeftChild(root));
			term(RightChild(root));
		}else{
			term(root);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

void term(tree root){
	if(IsNull(root))
		return;
	if(NodeKind(root) == EXPRNode){ // possibly add empty if statements for mult and div
		if(NodeOp(root) == AndOp){
			term(LeftChild(root));
			factor(RightChild(root));
		}else{
			factor(root);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

void factor(tree root){
	if(IsNull(root))
		return;
	if(NodeKind(root) == EXPRNode){
		if(NodeOp(root) == VarOp){
			var(root);
		}else if(NodeOp(root) == RoutineCallOp){
			routineCallOp(root);
		}else{
			expression(root);
		}
	}else{
		error_msg(STRING_MIS, CONTINUE, IntVal(root), 0);
	}
}

void routineCallOp(tree root){
	tree left = LeftChild(root);
	int varName = var(left);
	if(varName == 0)
		return;
	//output method?
	/*
	if(!strcmp(getname(GetAttr(varName,NAME_ATTR)), "println")){
		outputMethod = 1; // do not know what this does
	}
	*/
	if(GetAttr(varName,KIND_ATTR) != PROCE && GetAttr(varName, KIND_ATTR) != FUNC){
		error_msg(PROCE_MISMATCH, CONTINUE, GetAttr(varName, NAME_ATTR), 0);
		return;
	}
	//check arguments? count dimensions
	rightRec(RightChild(root));
}


void argument(tree root){
	tree left = LeftChild(root);
	tree name = LeftChild(left);
	tree type = RightChild(left);
	int nSymInd = InsertEntry(IntVal(name));
	if(NodeOp(root) == RArgTypeOp){
		SetAttr(nSymInd, KIND_ATTR, REF_ARG);
	}else{
		SetAttr(nSymInd, KIND_ATTR, VALUE_ARG);
	}
	SetAttr(nSymInd, TYPE_ATTR, type);
	//set node kind?
	/*
	setNodeKind(name, STNode);
	setIntVal(name, nSymInd);
	*/
}

//return index of variable in symbolTable
int var(tree root){
	if(NodeKind(root) == EXPRNode){
		tree varName = LeftChild(root);
		int nSymInd = LookUp(IntVal(varName));
		if(nSymInd == 0)
			return 0;
		// set node kind?
		//int index = findClass(nSymInd);
		tree right = RightChild(root);
		while(!IsNull(right)){
			if(NodeOp(LeftChild(right)) == IndexOp){
				if(IsAttr(nSymInd, KIND_ATTR)){
					if(GetAttr(nSymInd, KIND_ATTR) != ARR){
						error_msg(ARR_TYPE_MIS, CONTINUE, GetAttr(nSymInd, NAME_ATTR), 0);
						right = RightChild(right);
						continue;
					}
				}
				expression(LeftChild(LeftChild(right)));
			}
			//if fieldOp?
		}
		if(IsAttr(nSymInd, KIND_ATTR)){
				if(GetAttr(nSymInd, KIND_ATTR) == ARR){
					error_msg(INDX_MIS, CONTINUE, GetAttr(nSymInd, NAME_ATTR), 0);
				}
		}
		return nSymInd;
	}else
		return;
}

//analyze array
void array(tree root, int nSymInd){
	//start of array
	tree initial = LeftChild(root);
	if(IsNull(initial))
		return;
	//array initialization
	if(NodeOp(initial) == CommaOp){
		arrayInitialize(initial, nSymInd);
	}else{
		//array creation
		arrayCreate(initial, nSymInd);
	}
}

//array initialization
void arrayInitialize(tree root, int nSymInd){
	if(IsNull(root))
		return;
	arrayInitialize(LeftChild(root), nSymInd);
	varInt(RightChild(root), nSymInd);
}

//array creation
void arrayCreate(tree root, int nSymInd){
	//add out of bounds error
	//dimensions?
	traverse_recursive(root);
}

//analyze returnOp
void returnOp(tree root){
	expression(LeftChild(root));
}

//analyze loopOp
void loopOp(tree root){
	expression(LeftChild(root));
	traverse_recursive(RightChild(root));
}

//analyze assignOp
void assignOp(tree root){
	tree variable = RightChild(LeftChild(root));
	var(variable);
	tree right = RightChild(root);
	expression(right);
}

//analyze ifElseOp
void ifElseOp(tree root){
	if(IsNull(root))
		return;
	ifElseOp(LeftChild(root));
	if(NodeOp(RightChild(root)) == CommaOp){
		expression(LeftChild(RightChild(root)));
		traverse_recursive(RightChild(RightChild(root)));
	}
	if(NodeOp(RightChild(root)) == StmtOp)
		traverse_recursive(RightChild(root));
}

int main(int argc, char* argv){
	treelst = stdout;
	yyparse();

	STInit();
	traverse();
	STPrint();
	
	printtree(root,0);
	
	
} 
