%{
#include "parser.h"
#include "ComplexNode.h"

// this is called before every code block when a match is found
// line increment is handled in matched newline
// TODO problem with strings that span multiple lines?
#define YY_USER_ACTION \
    yylloc.first_column = yylloc.last_column; \
    yylloc.last_column += yyleng;
%}

letter          [A-Za-z]
digit           [0-9]
digits          [0-9]+
string          [^\"]*
identifier      {letter}({letter}|{digit})*
type            ("Int"|"Num"|"String"|"Point"|"Path"|"Term")
unary           (sin|cos|ln|abs)
pm              [-+]
integer         {pm}?{digits}
float           {pm}?{digits}\.{digits}?(E{pm}?{digits})?

%option yylineno
%option noyywrap
%%

[,;:(){}+*/-] {
  /* control characters are returned as literal characters */
  return yytext[0];
}

":=" {
  return ASSIGNMENT;
}

"<-" {
  return BINDING;
}

"to" {
  return TO;
}

"do" {
  return DO;
}

"<<" {
  return PATH_OPEN;
}

">>" {
  return PATH_CLOSE;
}

"var" {
  return VAR;
}

"arc" {
  return ARC;
}

"mod" {
  return MOD;
}

"end" {
  return END;
}

"for" {
  return FOR;
}

"draw" {
  return DRAW;
}

"fill" {
  return FILL;
}

"plot" {
  return PLOT;
}

"clip" {
  return CLIP;
}

"step" {
  return STEP;
}

"done" {
  return DONE;
}

"start" {
  return START;
}

"write" {
  return WRITE;
}

"rotate" {
  return ROTATE;
}

"scale" {
  return SCALE;
}

"union" {
  return UNION;
}

"concat" {
  return CONCAT;
}

"picture" {
  return PICTURE;
}

"scaletobox" {
  return SCALETOBOX;
}

"translate" {
  return TRANSLATE;
}

"ellipse" {
  return ELLIPSE;
}

"string2path" {
  return STRING2PATH;
}

"num2string" {
  return NUM2STRING;
}

"setcolor" {
  return SETCOLOR;
}

"setfont" {
  return SETFONT;
}

"setdrawstyle" {
  return SETDRAWSTYLE;
}

"setlinewidth" {
  return SETLINEWIDTH;
}

{type} {
  return TYPE;
}

{integer} {
  yylval.content = new ComplexNode{yytext};
  return INT;
}

{float} {
  yylval.content = new ComplexNode{yytext};
  return NUM;
}

{unary} {
  yylval.content = new ComplexNode{yytext};
  return UNARY;
}

("random"|"exp") {
  yylval.content = new ComplexNode{yytext};
  return BINARY;
}

%.*$ {
  // printf("Swallowed comment\n");
}

[ \t] {
  // printf("Swallowed whitespace\n");
}

[\n] {
  // need this rule for flex to increment yylineno;
  // and we use it to tell bison where we are
  yylloc.first_line = yylineno;
  yylloc.last_line = yylineno;
  yylloc.first_column = 1;
  yylloc.last_column = 1;
}

\"{string}\" {
  // shortens string by one character
  yytext[yyleng-1] = '\0';
  yylval.content = new ComplexNode{yytext+1};
  return STR;
}

{identifier} {
  yylval.content = new ComplexNode{yytext};
  return ID;
}

. {
  printf("no rule for %s ", yytext);
  return yytext[0];
}

%%
