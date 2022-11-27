%{
#include <stdio.h> /* for fprintf */
#include <iostream> /* for std::cout */
#include <cstring> /* for std::strcmp */
#include "ComplexNode.h"
#include <sstream> /* for buffering in actions */
extern int yylex();
extern void yyerror(char const* message);
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
%token <content> ID           /* [A-Za-z]([A-Za-z]|[0-9])* */
%token TYPE         /* (Int|Num|String|Point|Path|Term) */
%token <content> INT          /* [-+]?[0-9]+ */
%token <content> NUM          /* {-+}?{digits}\.{digits}?(E{sign}?{digits})? */
%token <content> STR          /* [^\"]* */
%token <content> UNARY        /* (sin|cos|ln|abs) */
%token <content> BINARY       /* random */

%start Program

%union {
  struct ComplexNode* content;
}

/* when a nonterminal carries data from a %union, is has
to be declared which type it carries */
%type <content> Block
%type <content> Cmd
%type <content> Cmds
%type <content> Def
%type <content> Factor
%type <content> Loop
%type <content> NumConst
%type <content> NumExpr
%type <content> NumTerm
%type <content> OptionCmd
%type <content> PaintCmd
%type <content> Path
%type <content> PathDef
%type <content> PathVal
%type <content> Point
%type <content> PointList
%type <content> PointVal
%type <content> StringVal
%type <content> TermCmd
%type <content> TermVal
%type <content> Value
%type <content> ValueExpr
%%
Program     : PICTURE STR Decls START Cmds END
              {
                std::cout << "%!PS-Adobe\n";
                std::cout << $5->code << "\n";
                std::cout << "showpage\n";
                delete $5;
              }
            | PICTURE STR START Cmds END
              {
                std::cout << "%!PS-Adobe\n";
                std::cout << $4->code << "\n";
                std::cout << "showpage\n";
                delete $4;
              }
            ;
Decls       : Decls Dec
              {
                // fprintf(stdout, "Decls -> Decls Dec\n");
              }
            | Dec
              {
                // fprintf(stdout, "Decls -> Dec\n");
              }
            ;
Dec         : VAR ID ':' TYPE ';'
              {
                // fprintf(stdout, "Dec -> VAR ID ':' TYPE ';'\n");
              }
            ;
Def         : ID ASSIGNMENT ValueExpr
              {
                std::stringstream buffer;
                buffer << "/" << $1->code << " {" << $3->code << "} def";
                $$ = new ComplexNode{buffer.str()};
                delete $1;
                delete $3;
                // fprintf(stdout, "Def -> ID ASSIGNMENT ValueExpr\n");
              }
            | ID BINDING ValueExpr
              {
                std::stringstream buffer;
                buffer << "/" << $1->code << " {" << $3->code << "} bind def";
                $$ = new ComplexNode{buffer.str()};
                delete $1;
                delete $3;
                // fprintf(stdout, "Def -> ID BINDING ValueExpr\n");
              }
            ;
ValueExpr   : Block
              {
                $$ = $1;
                // fprintf(stdout, "ValueExpr -> Block\n");
              }
            | Value
              {
                $$ = $1;
                // fprintf(stdout, "ValueExpr -> Value\n");
              }
            ;
Block       : '{' Cmds '}'
              {
                // $$ = new ComplexNode{"{" + $2->code + "}"};
                // delete $2;
                $$ = $2;
                // fprintf(stdout, "Block -> '{' Cmds '}'\n");
              }
            ;
Value       : NumExpr
              {
                $$ = $1;
                // fprintf(stdout, "Value -> NumExpr\n");
              }
            | STR
              {
                $$ = new ComplexNode{"(" + $1->code + ")"};
                delete $1;
                // fprintf(stdout, "Value -> STR\n");
              }
            | Point
              {
                $$ = $1;
                // fprintf(stdout, "Value -> Point\n");
              }
            | Path
              {
                $$ = $1;
                // fprintf(stdout, "Value -> Path\n");
              }
            ;
Point       : '(' NumExpr ',' NumExpr ')'
              {
                $$ = new ComplexNode{$2->code + " " + $4->code};
                delete $2;
                delete $4;
                // fprintf(stdout, "Point -> '(' NumExpr ',' NumExpr ')'\n");
              }
            ;
NumExpr     : NumExpr '-' NumTerm
                {
                  $$ = new ComplexNode{$1->code + " " + $3->code + " sub"};
                  delete $1;
                  delete $3;
                  // fprintf(stdout, "NumExpr -> NumExpr '-' NumTerm\n");
                }
            | NumExpr '+' NumTerm
                {
                  $$ = new ComplexNode{$1->code + " " + $3->code + " add"};
                  delete $1;
                  delete $3;
                  // fprintf(stdout, "NumExpr -> NumExpr '+' NumTerm\n");
                }
            | NumTerm
              {
                $$ = $1;
                // fprintf(stdout, "NumExpr -> NumTerm\n");
              }
            ;
NumTerm     : NumTerm '*' Factor
                {
                  $$ = new ComplexNode{$1->code + " " + $3->code + " mul"};
                  delete $1;
                  delete $3;
                  // fprintf(stdout, "NumTerm -> NumTerm '*' Factor\n");
                }
            | NumTerm '/' Factor
                {
                  $$ = new ComplexNode{$1->code + " " + $3->code + " div"};
                  delete $1;
                  delete $3;
                  // fprintf(stdout, "NumTerm -> NumTerm '/' Factor\n");
                }
            | NumTerm MOD Factor
                {
                  $$ = new ComplexNode{$1->code + " " + $3->code + " mod"};
                  delete $1;
                  delete $3;
                  // fprintf(stdout, "NumTerm -> NumTerm MOD Factor\n");
                }
            | Factor
              {
                $$ = $1;
                // fprintf(stdout, "NumExpr -> Factor\n");
              }
            ;
Factor      : '(' NumExpr ')'
              {
                $$ = $2;
                // fprintf(stdout, "Factor -> '(' NumExpr ')'\n");
              }
            | UNARY '(' NumExpr ')'
              {
                $$ = new ComplexNode{$3->code + " " + $1->code};
                delete $1;
                delete $3;
                // fprintf(stdout, "Factor -> UNARY '(' NumExpr ')'\n");
              }
            | BINARY Point
              {
                $$ = new ComplexNode{$2->code + " " + $1->code};
                delete $1;
                delete $2;
                // fprintf(stdout, "Factor -> BINARY Point\n");
              } // out of context reuse of Point
            | NumConst
              {
                $$ = $1;
                // fprintf(stdout, "Factor -> NumConst\n");
              }
            ;
NumConst    : INT
              {
                $$ = $1;
                // fprintf(stdout, "NumConst -> INT\n");
              }
            | NUM
              {
                $$ = $1;
                // fprintf(stdout, "NumConst -> NUM\n");
              }
            | ID
              {
                $$ = $1;
                // fprintf(stdout, "NumConst -> ID\n");
              }
            ;
PointVal    : Point
              {
                $$ = $1;
                // fprintf(stdout, "PointVal -> Point\n");
              }
            | ID
              {
                $$ = $1;
                // fprintf(stdout, "PointVal -> ID\n");
              }
            ;
StringVal   : STR
              {
                $$ = new ComplexNode{"(" + $1->code + ")"};
                delete $1;
                // fprintf(stdout, "StringVal -> STR\n");
              }
            | ID {} // default $$ = $1 is fine
            | NUM2STRING '(' NumExpr ')'
              {
                $$ = new ComplexNode{"(" + $3->code + ")"};
                delete $3;
                // fprintf(stdout, "StringVal -> NUM2STRING\n");
              }
            ;
PathVal     : Path
              {
                $$ = $1;
                // fprintf(stdout, "PathVal -> Path\n");
              }
            | ID
              {
                $$ = $1;
                // fprintf(stdout, "PathVal -> ID\n");
              }
            ;
Path        : PATH_OPEN PointList PATH_CLOSE
              {
                $$ = new ComplexNode{"newpath " + $2->code};
                delete $2;
                // fprintf(stdout, "Path -> PATH_OPEN PointList PATH_CLOSE\n");
              }
            | PathDef
              {
                $$ = $1;
                // fprintf(stdout, "Path -> PathDef\n");
              }
            ;
PathDef     : UNION '(' PathVal ',' PathVal ')'
              {
                yyerror("Not implemented!");
                YYERROR;
              }
            | CONCAT '(' PathVal ',' PathVal ')'
              {
                yyerror("Not implemented!");
                YYERROR;
              }
            | ARC '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ')'
              {
                std::stringstream buffer;
                buffer << "/savematrix matrix currentmatrix def\n";
                buffer << $3->code << " translate\n";
                buffer << "0 0 " << $5->code << $7->code << " " << $9->code << " arc\n";
                buffer << "savematrix setmatrix";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                delete $7;
                delete $9;
                // fprintf(stdout, "PathDef -> ARC '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ')'\n");
              }
            | ELLIPSE '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ')'
              {
                std::stringstream buffer;
                buffer << "/savematrix matrix currentmatrix def\n";
                buffer << $3->code << " translate\n";
                buffer << $5->code << " " << $7->code << " scale\n";
                buffer << "0 0 1 " << $9->code << " " << $11->code << " arc\n";
                buffer << "savematrix setmatrix";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                delete $7;
                delete $9;
                delete $11;
                // fprintf(stdout, "PathDef -> ELLIPSE '(' PointVal ',' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ')'\n");
              }
            | PLOT '(' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ',' NumExpr ',' '(' ID ',' NumExpr ')' ')'
              {
                yyerror("Not implemented!");
                YYERROR;
              }
            | SCALETOBOX '(' NumExpr ',' NumExpr ',' PathVal ')'
              {
                yyerror("Not implemented!");
                YYERROR;
              }
            | STRING2PATH '(' PointVal ',' StringVal ')'
              {
                std::stringstream buffer;
                buffer << "newpath " << $3->code << " moveto\n";
                buffer << $5->code << " false charpath\n";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                // fprintf(stdout, "PathDef -> STRING2PATH '(' PointVal ',' StringVal ')'\n");
              }
            ;
PointList   : PointList ',' PointVal
              {
                std::stringstream buffer;
                buffer << $1->code << " ";
                buffer << $3->code << " lineto";
                $$ = new ComplexNode{buffer.str()};
                delete $1;
                delete $3;
                // fprintf(stdout, "PointList -> PointList ',' PointVal\n");
              }
            | PointVal
              {
                std::stringstream buffer;
                buffer << $1->code << " moveto";
                $$ = new ComplexNode{buffer.str()};
                delete $1;
                // fprintf(stdout, "PointList -> PointVal\n");
              }
            ;
TermVal     : Block
              {
                $$ = $1;
                // fprintf(stdout, "TermVal -> Block\n");
              }
            | PaintCmd
              {
                $$ = $1;
                // fprintf(stdout, "TermVal -> PaintCmd\n");
              }
            | TermCmd
              {
                $$ = $1;
                // fprintf(stdout, "TermVal -> TermCmd\n");
              }
            | ID
              {
                $$ = $1;
                // fprintf(stdout, "TermVal -> ID\n");
              }
            ;
Cmds        : Cmds Cmd
              {
                $$ = new ComplexNode{$1->code + "\n" + $2->code};
                delete $1;
                delete $2;
                // fprintf(stdout, "Cmds -> Cmds Cmd\n");
              }
            | Cmd
              {
                $$ = $1;
                // fprintf(stdout, "Cmds -> Cmd\n");
              }
            ;
Cmd         : Def ';'
              {
                // fprintf(stdout, "Cmd -> Def\n");
              }
            | OptionCmd ';'
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> OptionCmd\n");
              }
            | PaintCmd ';'
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> PaintCmd\n");
              }
            | TermCmd ';'
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> TermCmd\n");
              }
            | Loop ';'
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> Loop\n");
              }
            | ID ';'
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> ID\n");
              }
            | Block
              {
                $$ = $1;
                // fprintf(stdout, "Cmd -> Block\n");
              }
            ;
OptionCmd   : SETCOLOR '(' NumExpr ',' NumExpr ',' NumExpr ')'
              {
                std::stringstream buffer;
                buffer << $3->code ;
                buffer << " ";
                buffer << $5->code;
                buffer << " ";
                buffer << $7->code;
                buffer << " setrgbcolor";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                delete $7;
                // fprintf(stdout, "OptionCmd -> SETCOLOR '(' NumExpr ',' NumExpr ',' NumExpr ')'\n");
              }
            | SETDRAWSTYLE '(' NumExpr ',' NumExpr ')'
              {
                $$ = new ComplexNode{"[" + $3->code + " " + $5->code + "]" + " 0 setdash"};
                delete $3;
                delete $5;
                // fprintf(stdout, "OptionCmd -> SETDRAWSTYLE '(' NumExpr ',' NumExpr ')'\n");
              }
            | SETFONT '(' StringVal ',' NumExpr ')'
              {
                std::stringstream buffer;
                buffer << $3->code << " findfont\n";
                buffer << $5->code << " scalefont\n";
                buffer << "setfont";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                // fprintf(stdout, "OptionCmd -> SETFONT '(' StringVal ',' NumExpr ')'\n");
              }
            | SETLINEWIDTH '(' NumExpr ')'
              {
                $$ = new ComplexNode{$3->code + " setlinewidth"};
                delete $3;
                // fprintf(stdout, "OptionCmd -> SETLINEWIDTH '(' NumExpr ')'\n");
              }
            ;
PaintCmd    : DRAW '(' PathVal ')'
              {
                $$ = new ComplexNode{$3->code + "\nstroke"};
                delete $3;
                // fprintf(stdout, "PaintCmd -> DRAW '(' PathVal ')'\n");
              }
            | FILL '(' PathVal ')'
              {
                $$ = new ComplexNode{$3->code + " closepath fill"};
                delete $3;
                // fprintf(stdout, "PaintCmd -> FILL '(' PathVal ')'\n");
              }
            | WRITE '(' StringVal ')'
              {
                $$ = new ComplexNode{$3->code + " show"};
                delete $3;
                // fprintf(stdout, "PaintCmd -> WRITE '(' StringVal ')'\n");
              }
            | WRITE '(' PointVal ',' StringVal ')'
              {
                std::stringstream buffer;
                buffer << $3->code + " moveto\n";
                buffer << $5->code + " show";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                // fprintf(stdout, "PaintCmd -> WRITE '(' PointVal ',' StringVal ')'\n");
              }
            ;
TermCmd     : ROTATE '(' NumExpr ',' TermVal ')'
              {
                std::stringstream buffer;
                buffer << "/savematrix matrix currentmatrix def\n";
                buffer << $3->code << " rotate\n";
                buffer << $5->code << "\n";
                buffer << "savematrix setmatrix\n";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                // fprintf(stdout, "TermCmd -> ROTATE '(' NumExpr ',' TermVal ')'\n");
              }
            | SCALE '(' NumExpr ',' NumExpr ',' TermVal ')'
              {
                std::stringstream buffer;
                buffer << "/savematrix matrix currentmatrix def\n";
                buffer << $3->code << " " << $5->code << " scale\n";
                buffer << $7->code << "\n";
                buffer << "savematrix setmatrix";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                delete $7;
                // fprintf(stdout, "TermCmd -> SCALE '(' NumExpr ',' NumExpr ',' TermVal ')'\n");
              }
            | TRANSLATE '(' NumExpr ',' NumExpr ',' TermVal ')'
              {
                std::stringstream buffer;
                buffer << "/savematrix matrix currentmatrix def\n";
                buffer << $3->code << " " << $5->code << " translate\n";
                buffer << $7->code << "\n";
                buffer << "savematrix setmatrix";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                delete $7;
                // fprintf(stdout, "TermCmd -> TRANSLATE '(' NumExpr ',' NumExpr ',' TermVal ')'\n");
              }
            | CLIP '(' PathVal ',' TermVal ')'
              {
                std::stringstream buffer;
                buffer << "clipsave\n";
                buffer << $3->code << " clip\n";
                buffer << $5->code << "\n";
                buffer << "cliprestore\n";
                $$ = new ComplexNode{buffer.str()};
                delete $3;
                delete $5;
                // fprintf(stdout, "TermCmd -> CLIP '(' PathVal ',' TermVal ')'\n");
              }
            ;
Loop        : FOR ID ASSIGNMENT NumExpr TO NumExpr STEP NumExpr DO Cmds DONE
              {
                $$ = new ComplexNode{$4->code + " " + $6->code + " " + $8->code + "\n" + $10->code + "\nfor"};
                delete $4;
                delete $6;
                delete $8;
                delete $10;
                // fprintf(stdout, "Loop -> FOR ID ASSIGNMENT NumExpr TO NumExpr STEP NumExpr DO Cmds DONE\n");
              }
            ;
%%

void yyerror(char const* message) {
  fprintf(stderr, "\n");
  fprintf(stderr, "%s\n", message);
  fprintf(stderr, "in line %d, column %d-%d\n", yylloc.first_line, yylloc.first_column, yylloc.last_column);
  fprintf(stderr, "\n");
}

int main(int argc, char* argv[]) {
  /* Enable parse traces on option -p. */
  if (argc == 2 && std::strcmp(argv[1], "-p") == 0) {
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