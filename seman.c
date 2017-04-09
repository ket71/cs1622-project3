#include "proj2.h"
#include "proj3.h"
#include <stdio.h>
#include <string.h>

extern FILE* treelst;
extern tree root;
extern int error;

void traverse();
void traverse_recursive(tree root);


void traverse(){
	traverse_recursive(root);
}

void traverse(tree root){
	if(IsNull(root)){
		printf("null");
		return;
	}
}

int main(int argc, char* argv){

} 
