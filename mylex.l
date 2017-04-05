%{
#include <stdlib.h>
#include <string.h>


#define LIMIT1 500
extern int yycolumn, yylength, yyline;
extern YYSTYPE yylval;
int sIndex;
char buffer[LIMIT1];
void reportError(char err[]);
void printTable();
void addString(char s[]);


%}

/* regular definitions */

digit 		[0-9]
comments	  "/*"[^"*/"]*"*/"
BADCOMMENTS   "/*"[^"*/"]*
PROGRAM 	[Pp][Rr][Oo][Gg][Rr][Aa][Mm][^\n]
DECLARATION	[Dd][Ee][Cc][Ll][Aa][Rr][Aa][Tt][Ii][Oo][Nn][Ss]    
ENDDECLARATIONS	[Ee][Nn][Dd][Dd][Ee][Cc][Ll][Aa][Rr][Aa][Tt][Ii][Oo][Nn][Ss]
INT				[Ii][Nn][Tt]
METHOD			[Mm][Ee][Tt][Hh][Oo][Dd]		
VAL				[Vv][Aa][Ll]	
WHILE			[Ww][Hh][Ii][Ll][Ee]	
CLASS			[Cc][Ll][Aa][Ss][Ss]
ELSE			[Ee][Ll][Ss][Ee] 
ICONST			([1-9]{digit}*|0) 
IF				[Ii][Ff] 
NOT				"!"
RETURN			[Rr][Ee][Tt][Uu][Rr][Nn]
SCONST			"'"[^\n']+"'"
BADSCONST		['’][^\n’']+[\n]
TIMES			"*"
VOID			[Vv][Oo][Ii][Dd]  
ID            [A-Za-z][A-Za-z0-9]* 
BADID		[0-9][A-Za-z0-9]* 
delim         [ \t] 	
ws            {delim}+ 
NEWLINE       [\n] 


%%
{comments} {int i; for(i = 0; yytext[i] != '\0'; i++){ if(yytext[i] == '\n'){ yyline++; yycolumn=0;yyleng =0;}};}
{DECLARATION}	{yycolumn+=yyleng; return DECLARATIONSnum;}
{ENDDECLARATIONS}	{yycolumn+=yyleng; return ENDDECLARATIONSnum;}
{NEWLINE}           {yyline++; yycolumn=0;yyleng =0;}
{CLASS}		{yycolumn+=yyleng; return CLASSnum;}
{PROGRAM}	{yycolumn+=yyleng; return PROGRAMnum;}
{METHOD}	{yycolumn+=yyleng; return METHODnum;}
{SCONST} {yycolumn+=yyleng; addString(yytext); return SCONSTnum;}
"!"		{yycolumn+=yyleng; return NOTnum;}
"&&"		{yycolumn+=yyleng; return ANDnum;}
{ws}		{yycolumn+=yyleng; int i; for(i = 0; yytext[i] != '\0'; i++){ if(yytext[i] == '\t'){ yycolumn +=3;}};}
"."		{yycolumn+=yyleng; return DOTnum;}
"="		{yycolumn+=yyleng; return EQUALnum;}
">"		{yycolumn+=yyleng; return GTnum;}
{INT}		{yycolumn+=yyleng;yylval.intg = atoi(yytext); return INTnum;}
{ICONST}		{yycolumn+=yyleng; yylval.intg = atoi(yytext); return ICONSTnum;}
"["		{yycolumn+=yyleng; return LBRACnum;}
":="		{yycolumn+=yyleng; return ASSGNnum;}
"!="		{yycolumn+=yyleng; return NEnum;}
"||"		{yycolumn+=yyleng; return ORnum;}
"]"		{yycolumn+=yyleng; return RBRACnum;}
";"		{yycolumn+=yyleng; return SEMInum;}
{VAL}		{yycolumn+=yyleng; return VALnum;}
{WHILE}		{yycolumn+=yyleng; return WHILEnum;}
","	{yycolumn+=yyleng; return COMMAnum;}
"/"	{yycolumn+=yyleng; return DIVIDEnum;}
{ELSE}		{yycolumn+=yyleng; return ELSEnum;}
"=="		{yycolumn+=yyleng; return EQnum;}
">="		{yycolumn+=yyleng; return GEnum;}
{IF}		{yycolumn+=yyleng; return IFnum;}
"{"	{yycolumn+=yyleng; return LBRACEnum;}
"<="		{yycolumn+=yyleng; return LEnum;}
"<"		{yycolumn+=yyleng; return LTnum;}
"-"		{yycolumn+=yyleng; return MINUSnum;}
"+"		{yycolumn+=yyleng; return PLUSnum;}
"}"		{yycolumn+=yyleng; return RBRACEnum;}
{RETURN}		{yycolumn+=yyleng; return RETURNnum;}
"*"		{yycolumn+=yyleng; return TIMESnum;}
{VOID}		{yycolumn+=yyleng; return VOIDnum;}
{ID}		    {yycolumn+=yyleng; addString(yytext); return IDnum;}
"(" {yycolumn+=yyleng; return LPARENnum;}
")"	{yycolumn+=yyleng; return RPARENnum;}
{BADCOMMENTS} {yycolumn+=yyleng;  char *err = "COMMENT"; reportError(err);int i; for(i = 0; yytext[i] != '\0'; i++){ if(yytext[i] == '\n'){ yyline++; yycolumn=0;yyleng =0;}};}
{BADSCONST} {yycolumn+=yyleng;  char *err = "SCONST";reportError(err); yyline++;yycolumn=0;yyleng =0;}
{BADID}	{yycolumn+=yyleng; char *err = "ID"; reportError(err);}
%%

YYSTYPE yylval;
int yyline =0;
int yycolumn = 0;
char symbolTable[LIMIT1 + 1];//string table
int sIndex = 0; //Index to keep track of string constants in string table
int searchIndex = 0; //search index for string table


/* Array to match token names to their token numbers */
char * tokens[] = {"ANDnum","ASSGNnum","DECLARATIONSnum","DOTnum","ENDDECLARATIONSnum","EQUALnum",
					"GTnum","IDnum","INTnum","LBRACnum","LPARENnum","METHODnum","NEnum","ORnum","PROGRAMnum",
					"RBRACnum","RPARENnum","SEMInum","VALnum","WHILEnum","CLASSnum","COMMAnum","DIVIDEnum","ELSEnum",
					"EQnum","GEnum","ICONSTnum","IFnum","LBRACEnum","LEnum","LTnum","MINUSnum","NOTnum","PLUSnum",
					"RBRACEnum","RETURNnum","SCONSTnum","TIMESnum","VOIDnum"
					};


/*report string constant, id, and comment error*/
void reportError(char err[]){
		printf("Line: %d, Column %d %s Error.\n", yyline, yycolumn, err);
}

/* search to see if s is already in string table */
int Find(char s[]){
	int i = 0;
	char word[LIMIT1];
	symbolTable[LIMIT1] = '\0';
	while(i < LIMIT1){
		strcpy(&word[0], &symbolTable[i]);
		//compares word in string table with string s
		if(!strcasecmp(word, s)){
			return i;
		}else{
			i = i + strlen(word);
		}
		i++;
	}
	return -1;
}

/* makes string lowercase so that when looking for a string, we can look for it in lowercase form */
char *toLowerCase(char s[]){
	int i;
	for(i = 0; i < yyleng; i++){
		if('A' <= s[i] && s[i] <= 'Z'){
			s[i] = s[i] - 'A' + 'a';	
		}
	
	}
	return s;
}

/* inserts s into string table */
int insert(char s[]){
	if(strlen(s) + sIndex >= LIMIT1){
		printf("Not enough space in string table.");
		return -1;
	}
	strcpy(&symbolTable[sIndex], s);
	int temp = sIndex;
	sIndex += strlen(s) + 1;
	return temp;
}


/* adds string to string table */
void addString(char s[]){
	/* find if s is already in string table */
	int searchIndex = Find(s);
	/* if not, add it to the string table */
	if(searchIndex == -1){
		/*lowercase allows for consistency when looking for a string */
		s = toLowerCase(s);
		yylval.intg = insert(s);
	}else{
		yylval.intg = searchIndex;
	}
}

/* Prints out string table */
void printTable(){
	printf("String Table : ");
	int i;
	for(i = 0; i < sIndex; i++){
		while(symbolTable[i] != '\0'){
				printf("%c", symbolTable[i]);
				i++;
		}
		printf("%c", ' ');
	
	}
	printf("\n");
}
