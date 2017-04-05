%{
#include  "proj2.h"
#include  <stdio.h>
  tree  type_tree; /* pointer to store type */
%}

%token <intg> ANDnum ASSGNnum DECLARATIONSnum DOTnum ENDDECLARATIONSnum EQUALnum
%token <intg> GTnum IDnum INTnum LBRACnum LPARENnum METHODnum NEnum ORnum PROGRAMnum
%token <intg> RBRACnum RPARENnum SEMInum VALnum WHILEnum CLASSnum COMMAnum DIVIDEnum ELSEnum
%token <intg> EQnum GEnum ICONSTnum IFnum LBRACEnum LEnum LTnum MINUSnum NOTnum PLUSnum
%token <intg> RBRACEnum RETURNnum SCONSTnum TIMESnum VOIDnum

%type  <tptr>  Program ClassDecl_recursive ClassDecl ClassBody ClassBody_MethodDecl 
%type  <tptr>  MethodDecl_recursive Decls Decls_recursive FieldDecl FieldDecl_recursive FieldDeclID
%type  <tptr>  VariableDeclID VariableDeclID_recursive VariableInitializer ArrayInitializer 
%type  <tptr>  ArrayInitializer_recursive ArrayCreationExpression ArrayCreationExpression_recursive
%type  <tptr>  ArrayExpression MethodDecl FormalParameterList FormalParameterList_recursive
%type  <tptr>  FormalParameter FormalParameter_recursive Block Type Type_recursive 
%type  <tptr>  StatementList StatementList_recursive Statement AssignmentStatement MethodCallStatement
%type  <tptr>  MethodCallStatement_recursive ReturnStatement IfStatement WhileStatement Expression
%type  <tptr> SimpleExpression SimpleExpression_recursive SimpleExpressionOp Term Term_recursive
%type  <tptr>  TermOp Factor UnsignedConstant Variable Variable_recursive Variable_expression



%%/* yacc specification*/
/* Program */
Program						:	PROGRAMnum IDnum SEMInum ClassDecl_recursive
								{  
									$$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2)); 
									printtree($$, 0);
								};
/* ClassDecl */								
ClassDecl_recursive   		:	ClassDecl                       
								{
									$$ = MakeTree(ClassOp, NullExp(), $1);
								} 
							|	ClassDecl_recursive ClassDecl
								{
									$$ = MakeTree(ClassOp, $1, $2);
								};
ClassDecl 					:	CLASSnum IDnum ClassBody
								{
									$$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2));
								}; 
/* ClassBody */
ClassBody					:	LBRACEnum Decls ClassBody_MethodDecl RBRACEnum
								{
									if ($3 == NullExp()) {
										$$ = $2;
									} else {
										$$ = MkLeftC($2, $3);
									}
								};
ClassBody_MethodDecl		:	MethodDecl_recursive
								{
									$$ = MakeTree(BodyOp, NullExp(), $1);
								}
							|	ClassBody_MethodDecl MethodDecl
								{
									$$ = MakeTree(BodyOp, $1, $2);
								};
MethodDecl_recursive				:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	MethodDecl
								{
									$$ = MakeTree(BodyOp, NullExp(), $1);
								};
/* Decls */
Decls						:	/* Epsilon */
								{
									$$ = NullExp();
								}	
							|	DECLARATIONSnum Decls_recursive ENDDECLARATIONSnum
								{
									$$ = $2;
								};
Decls_recursive				:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	FieldDecl
								{
									$$ = MakeTree(BodyOp, NullExp(), $1);
								}
							|	Decls_recursive FieldDecl
								{
									$$ = MakeTree(BodyOp, $1, $2);
								};
/* FieldDecl */
FieldDecl					:	Type FieldDecl_recursive SEMInum
								{
									$$ = $2;
								};
FieldDecl_recursive			:	FieldDeclID
								{
									$$ = MakeTree(DeclOp, NullExp(), $1);
								}
							|	FieldDecl_recursive COMMAnum FieldDeclID
								{
									$$ = MakeTree(DeclOp, $1, $3);
								};
FieldDeclID					:	VariableDeclID
								{
									tree commaTree = MakeTree(CommaOp, type_tree, NullExp());
									$$ = MakeTree(CommaOp, $1, commaTree);
								}
							|	VariableDeclID EQUALnum VariableInitializer
								{
									tree commaTree = MakeTree(CommaOp, type_tree, $3);
									$$ = MakeTree(CommaOp, $1, commaTree);
								};
/* VariableDeclID */
VariableDeclID				:	IDnum
								{
									$$ = MakeLeaf(IDNode, $1);
								}
							|	IDnum VariableDeclID_recursive
								{
									$$ = MakeLeaf(IDNode, $1);
								};
VariableDeclID_recursive	:	LBRACnum RBRACnum
								{
									$$ = $$;
								}
							|	VariableDeclID_recursive LBRACnum RBRACnum
								{
									$$ = $$;
								};
/* VariableInitializer */
VariableInitializer			:	Expression
								{
									$$ = $1;
								}
							|	ArrayInitializer
								{
									$$ = $1;
								}
							|	ArrayCreationExpression
								{
									$$ = $1;
								};
/* ArrayInitializer */
ArrayInitializer			:	LBRACEnum ArrayInitializer_recursive RBRACEnum
								{
									$$ = MakeTree(ArrayTypeOp, $2, type_tree);
								};
ArrayInitializer_recursive	:	Expression
								{
									$$ = MakeTree(CommaOp, NullExp(), $1);
								}
							|	ArrayInitializer_recursive COMMAnum Expression
								{
									$$ = MakeTree(CommaOp, $1, $3);
								};
/* ArrayCreationExpression */
ArrayCreationExpression		:	INTnum ArrayCreationExpression_recursive
								{
									$$ = MakeTree(ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, $1));
								};
ArrayCreationExpression_recursive	:	ArrayExpression
								{
									$$ = MakeTree(BoundOp, NullExp(), $1);
								}
							|	ArrayCreationExpression_recursive ArrayExpression
								{
									$$ = MakeTree(BoundOp, $1, $2);
								};
ArrayExpression				:	LBRACnum Expression RBRACnum
								{
									$$ = $2;
								};
/* MethodDecl */
MethodDecl					:	METHODnum Type IDnum LPARENnum FormalParameterList RPARENnum Block
								{
									tree headOp = MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5);
									$$ = MakeTree(MethodOp, headOp, $7);
								}
							|	METHODnum VOIDnum {type_tree = NullExp();} IDnum LPARENnum FormalParameterList RPARENnum Block
								{
									tree headOp = MakeTree(HeadOp, MakeLeaf(IDNode, $4), $6);
									$$ = MakeTree(MethodOp, headOp, $8);
								};
/* FormalParameterList */
FormalParameterList 		:	/* Epsilon */
								{
									$$ = MakeTree(SpecOp, NullExp(), type_tree);
								}
							|	FormalParameterList_recursive
								{
									$$ = MakeTree(SpecOp, $1, type_tree);
								};
FormalParameterList_recursive:	FormalParameter
								{
									$$ = $1;
								}
							|	FormalParameter SEMInum FormalParameterList_recursive
								{
									$$ = MkRightC($3, $1);
								};
FormalParameter				:	VALnum INTnum FormalParameter_recursive
								{
									$$ = $3;
								}		
							|	INTnum FormalParameter_recursive
								{
									$$ = $2;
								};
FormalParameter_recursive	:	IDnum 	
								{
									tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
									$$ = MakeTree(RArgTypeOp, idTree, NullExp());
								}
							|	IDnum COMMAnum FormalParameter_recursive
								{
									tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
									tree formalParameter = MakeTree(RArgTypeOp, idTree, NullExp());
									$$ = MkRightC($3, formalParameter);
								};
/* Block */		
Block						:	StatementList
								{
									$$ = MakeTree(BodyOp, NullExp(), $1);
								}
							|	Decls StatementList
								{
									$$ = MakeTree(BodyOp, $1, $2);
								};
/* Type */
Type						:	IDnum Type_recursive
								{
									$$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
								}
							|	INTnum Type_recursive
								{
									$$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
								}
							|	IDnum Type_recursive DOTnum Type
								{
									tree typeTree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
									tree fieldTree = MakeTree(FieldOp, $4, NullExp());
									$$ = type_tree = MkRightC(fieldTree, typeTree); 
								}
							|	INTnum Type_recursive DOTnum Type
								{
									tree typeTree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
									tree fieldTree = MakeTree(FieldOp, $4, NullExp());
									$$ = type_tree = MkRightC(fieldTree, typeTree);
								};
Type_recursive				:	/* Epsilon */
								{
									$$ = type_tree = NullExp();
								}
							|	LBRACnum RBRACnum
								{
									$$ = type_tree = MakeTree(IndexOp, NullExp(), NullExp());
								}
							|	Type_recursive LBRACnum RBRACnum
								{
									$$ = type_tree = MakeTree(IndexOp, NullExp(), $1);
								};
/* StatementList */
StatementList				:	LBRACEnum StatementList_recursive RBRACEnum
								{
									$$ = $2;
								};
StatementList_recursive		:	Statement
								{	
									$$ = MakeTree(StmtOp, NullExp(), $1);
								}
							|	StatementList_recursive SEMInum Statement
								{	
									if ($3 == NullExp()) {
										$$ = $1;
									} else { 
										$$ = MakeTree(StmtOp, $1, $3);
									}
								};
/* Statement */
Statement					:	/* Epsilon */
								{
									$$ = NullExp();
								}	
							|	AssignmentStatement
								{
									$$ = $1;
								}
							|	MethodCallStatement
								{
									$$ = $1;
								}
							|	ReturnStatement
								{
									$$ = $1;
								}
							|	IfStatement 
								{
									$$ = $1;
								}
							|	WhileStatement 
								{
									$$ = $1;
								};
/* AssignmentStatement */
AssignmentStatement			:	Variable ASSGNnum Expression
								{
									tree assignOp = MakeTree(AssignOp, NullExp(), $1);
									$$ = MakeTree(AssignOp, assignOp, $3);
								};
/* MethodCallStatement */
MethodCallStatement			:	Variable LPARENnum MethodCallStatement_recursive RPARENnum
								{
									$$ = MakeTree(RoutineCallOp, $1, $3);
								};
MethodCallStatement_recursive:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	Expression
								{
									$$ = MakeTree(CommaOp, $1, NullExp());
								}
							|	Expression COMMAnum MethodCallStatement_recursive
								{
									$$ = MakeTree(CommaOp, $1, $3);
								};
/* ReturnStatement */
ReturnStatement				:	RETURNnum // handles return statement "return;"
								{
									$$ = MakeTree(ReturnOp, NullExp(), NullExp());
								}
							|	RETURNnum Expression
								{
									$$ = MakeTree(ReturnOp, $2, NullExp());
								};
/* IfStatement */
IfStatement					:	IFnum Expression StatementList
								{
									tree commaTree = MakeTree(CommaOp, $2, $3);
									$$ = MakeTree(IfElseOp, NullExp(), commaTree);
								}
							|	IFnum Expression StatementList ELSEnum StatementList
								{
									tree commaTree = MakeTree(CommaOp, $2, $3);
									tree ifTree = MakeTree(IfElseOp, NullExp(), commaTree);
									$$ = MakeTree(IfElseOp, ifTree, $5);	
								};
/* WhileStatement */
WhileStatement				:	WHILEnum Expression StatementList
								{
									$$ = MakeTree(LoopOp, $2, $3);
								};
/* Expression */
Expression					:	SimpleExpression
								{
									$$ = $1;
								}
							|	SimpleExpression LTnum SimpleExpression
								{
									$$ = MakeTree(LTOp, $1, $3);
								}
							|	SimpleExpression LEnum SimpleExpression
								{
									$$ = MakeTree(LEOp, $1, $3);
								}
							|	SimpleExpression EQnum SimpleExpression
								{
									$$ = MakeTree(EQOp, $1, $3);
								}
							|	SimpleExpression NEnum SimpleExpression
								{
									$$ = MakeTree(NEOp, $1, $3);
								}
							|	SimpleExpression GEnum SimpleExpression
								{
									$$ = MakeTree(GEOp, $1, $3);
								}
							|	SimpleExpression GTnum SimpleExpression
								{
									$$ = MakeTree(GTOp, $1, $3);
								};
/* SimpleExpression */
SimpleExpression			:	Term SimpleExpression_recursive
								{
									if ($2 == NullExp()) {
										$$ = $1;
									} else {
										$$ = MkLeftC($1, $2);
									}
								}
							|	PLUSnum Term SimpleExpression_recursive
								{
									if ($3 == NullExp()) {
										$$ = $2;
									} else {
										$$ = MkLeftC($2, $3);
									}
								}
							|	MINUSnum Term SimpleExpression_recursive
								{
									tree neg = MakeTree(UnaryNegOp, $2, NullExp());
									if ($3 == NullExp()) {
										$$ = neg;
									} else {
										$$ = MkLeftC(neg, $3);
									}
								};
SimpleExpression_recursive	:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	SimpleExpressionOp SimpleExpression_recursive
								{
									if ($2 == NullExp()) {
										$$ = $1;
									} else {
										$$ = MkLeftC($1, $2);
									}
								};
/*Better to have SimpleExpressionOp rather than have "PLUSnum Term SimpleExpression_recursive" and others.
This is more efficient */
SimpleExpressionOp			:	PLUSnum Term
								{
									$$ = MakeTree(AddOp, NullExp(), $2);
								}
							|	MINUSnum Term
								{
									$$ = MakeTree(SubOp, NullExp(), $2);
								}
							|	ORnum Term
								{
									$$ = MakeTree(OrOp, NullExp(), $2);
								};
/* Term */
Term						:	Factor Term_recursive
								{
									if ($2 == NullExp()) {
										$$ = $1;
									} else {
										$$ = MkLeftC($1, $2);
									}
								};
Term_recursive				:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	TermOp Term_recursive
								{
									if ($2 == NullExp()) {
										$$ = $1;
									} else {
										$$ = MkLeftC($1, $2);
									}
								};
/*Reasoning for TermOp is the same as SimpleExpressionOp */
TermOp						:	TIMESnum Factor
								{
									$$ = MakeTree(MultOp, NullExp(), $2);
								}
							|	DIVIDEnum Factor
								{
									$$ = MakeTree(DivOp, NullExp(), $2);
								}
							|	ANDnum Factor
								{
									$$ = MakeTree(AndOp, NullExp(), $2);
								};
/* Factor */
Factor						:	UnsignedConstant
								{
									$$ = $1;
								}
							|	Variable
								{
									$$ = $1;
								}
							|	MethodCallStatement
								{
									$$ = $1;
								}
							|	LPARENnum Expression RPARENnum
								{
									$$ = $2;
								}
							|	NOTnum Factor
								{
									$$ = MakeTree(NotOp, $2, NullExp());
								};
/* UnsignedConstant */
UnsignedConstant			:	ICONSTnum
								{
									$$ = MakeLeaf(NUMNode, $1);
								}
							|	SCONSTnum
								{
									$$ = MakeLeaf(STRINGNode, $1);
								};
/* Variable */
Variable					:	IDnum Variable_recursive
								{
									$$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), $2);
								};
Variable_recursive 			:	/* Epsilon */
								{
									$$ = NullExp();
								}
							|	LBRACnum Variable_expression RBRACnum Variable_recursive
								{
									$$ = MakeTree(SelectOp, $2, $4); 
								}
							|	DOTnum IDnum Variable_recursive
								{
									tree dot = MakeTree(FieldOp, MakeLeaf(IDNode, $2), NullExp());
									$$ = MakeTree(SelectOp, dot, $3);
								};
Variable_expression			:	Expression
								{
									$$ = MakeTree(IndexOp, $1, NullExp());
								}
							|	Expression COMMAnum Variable_expression
								{
									$$ = MakeTree(IndexOp, $1, $3);
								};
%%
/* C code */
int yycolumn, yyline;

FILE *treelst;

main()
{
  treelst = stdout;
  yyparse();
}

yyerror(char *str)
{
  printf("yyerror: %s at line %d\n", str, yyline);
}

#include "lex.yy.c"