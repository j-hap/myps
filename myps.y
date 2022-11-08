%{
#include <stdio.h> /* for fprintf */
#include <string.h> /* for strcmp */
extern int yylex();
extern void yyerror();
%}

%locations /* gives access to line numbers */
%define parse.error detailed /* verbose error messages */

/* control characters are returned as literal characters */
%token ASSIGNMENT   /* := */
%token BINDING      /* <- */
%token TO           /* to */
%token DO           /* do */
%token PATH_OPEN    /* << */
%token PATH_CLOSE   /* >> */
%token VAR          /* var */
%token ARC          /* arc */
%token MOD          /* mod */
%token END          /* end */
%token FOR          /* for */
%token DRAW         /* draw */
%token FILL         /* fill */
%token PLOT         /* plot */
%token CLIP         /* clip */
%token STEP         /* step */
%token DONE         /* done */
%token START        /* start */
%token WRITE        /* write */
%token ROTATE       /* rotate */
%token SCALE        /* scale */
%token UNION        /* union */
%token CONCAT       /* concat */
%token PICTURE      /* picture */
%token SCALETOBOX   /* scaletobox */
%token TRANSLATE    /* translate */
%token ELLIPSE      /* ellipse */
%token STRING2PATH  /* string2path */
%token NUM2STRING   /* num2string */
%token SETCOLOR     /* setcolor */
%token SETFONT      /* setfont */
%token SETDRAWSTYLE /* setdrawstyle */
%token SETLINEWIDTH /* setlinewidth */
%token ID           /* [A-Za-z]([A-Za-z]|[0-9])* */
%token TYPE         /* (Int|Num|String|Point|Path|Term) */
%token INT          /* [-+]?[0-9]+ */
%token NUM          /* {-+}?{digits}\.{digits}?(E{sign}?{digits})? */
%token STR          /* [^\"]* */
%token UNARY        /* (sin|cos|ln|abs) */
%token BINARY       /* random */

%start Program
%%
Program     : PICTURE STR Decls START Cmds END { printf("reduced program 1\n"); }
            | PICTURE STR START Cmds END { printf("reduced program 2\n"); }
            ;
Decls       : Decls Dec {}
            | Dec {}
            ;
Dec         : VAR ID ':' TYPE ';' {}
            ;
Def         : ID ASSIGNMENT ValueExpr {}
            | ID BINDING ValueExpr {}
            ;
ValueExpr   : Block {}
            | Value {}
            ;
Block       : '{' Cmds '}' {}
            ;
Value       : NumExpr {}
            | STR {}
            | Point {}
            | Path {}
            ;
Point       : '(' NumExpr ',' NumExpr ')' {}
            ;
NumExpr     : NumExpr '-' NumTerm {}
            | NumExpr '+' NumTerm {}
            | NumTerm {}
            ;
NumTerm     : NumTerm '*' Factor {}
            | NumTerm '/' Factor {}
            | NumTerm MOD Factor {}
            | Factor {}
            ;
Factor      : '(' NumExpr ')' {}
            | UNARY '(' NumExpr ')' {}
            | BINARY Point {} /* out of context reuse of Point because I can */
            | NumConst {}
            ;
NumConst    : INT {}
            | NUM {}
            | ID {}
            ;
PointVal    : Point {}
            | ID {}
            ;
StringVal   : STR {}
            | ID {}
            | NUM2STRING '(' NumExpr ')' {}
            ;
PathVal     : Path {}
            | ID {}
            ;
Path        : PATH_OPEN PointList PATH_CLOSE {}
            | PathDef {}
            ;
PathDef     : UNION '(' PathVal ',' PathVal ')' {}
            | CONCAT '(' PathVal ',' PathVal ')' {}
            | ARC '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ')' {}
            | ELLIPSE '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ')' {}
            | PLOT '(' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ',' '(' ID ',' NumExpr ')' ')' {}
            | SCALETOBOX '(' NumExpr ',' NumExpr ',' PathVal ')' {}
            | STRING2PATH '(' PointVal ',' StringVal ')' {}
            ;
PointList   : PointList ',' PointVal {}
            | PointVal {}
            ;
TermVal     : Block {}
            | PaintCmd {}
            | TermCmd {}
            | ID {}
            ;
Cmds        : Cmds Cmd {}
            | Cmd {}
            ;
Cmd         : Def ';' {}
            | OptionCmd ';' {}
            | PaintCmd ';' {}
            | TermCmd ';' {}
            | Loop ';' {}
            | ID ';' {}
            | Block {}
            ;
OptionCmd   : SETCOLOR '(' NumExpr ',' NumExpr ',' NumExpr ')' {}
            | SETDRAWSTYLE '(' NumExpr ',' NumExpr ')' {}
            | SETFONT '(' StringVal ',' NumExpr ')' {}
            | SETLINEWIDTH '(' NumExpr ')' {}
            ;
PaintCmd    : DRAW '(' PathVal ')' {}
            | FILL '(' PathVal ')' {}
            | WRITE '(' StringVal ')' {}
            | WRITE '(' PointVal ',' StringVal ')' {}
            ;
TermCmd     : ROTATE '(' NumExpr ',' TermVal ')' {}
            | SCALE '(' NumExpr ',' NumExpr ',' TermVal ')' {}
            | TRANSLATE '(' NumExpr ',' NumExpr ',' TermVal ')' {}
            | CLIP '(' PathVal ',' TermVal ')' {}
            ;
Loop        : FOR ID ASSIGNMENT NumExpr TO NumExpr STEP NumExpr DO Cmds DONE {}
            ;
%%

void yyerror(char const* s) {
  fprintf(stderr, "\n");
  fprintf(stderr, "%s\n", s);
  fprintf(stderr, "in line %d, column %d-%d\n", yylloc.first_line, yylloc.first_column, yylloc.last_column);
  fprintf(stderr, "\n");
}

int main(int argc, char* argv[]) {
  /* Enable parse traces on option -p. */
  if (argc == 2 && strcmp(argv[1], "-p") == 0) {
    yydebug = 1;
  } else {
    yydebug = 0;
  }
  yylloc.first_line = 1;
  yylloc.last_line = 1;
  yylloc.first_column = 0;
  yylloc.last_column = 0;
  return yyparse();
}