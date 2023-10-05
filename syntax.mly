/* File syntax.mly */

%{ (* header *)
  
%} /* declarations */

%token EOL SEMICOLON COLON ASSIGN  /* lexer tokens */
%token EQUALS MINUS LBRACKET RBRACKET
%token VAR PROC SKIP TRUE FALSE 
%token <string> IDENT
%token <int> NUM
%start prog                   /* the entry point */
%type <unit> prog  
/* the header is copied in calculatorMENHIR.ml but
not is calculatorMENHIR.mli where typeProg must be
qualified by the module where the type is declared */
%type <unit> cmds
%type <unit> cmd
%type <unit> assign
%type <unit> declare
%type <unit> sequential_control
%type <unit> expr
%left MINUS          /* lowest precedence  */

%% /* rules */

prog :
    cmds EOL  { print_endline "Success!"; () }
	
cmds :
  | cmd SEMICOLON cmds   { () }
  | cmd                  { () }
  
cmd :
  | declare { () }
  | assign  { () }
  | expr    { () }
  | sequential_control { () }

boolean:
  | TRUE { () }
  | FALSE { () }
  | expr EQUALS expr { () }

sequential_control:
    | LBRACKET declare RBRACKET { () }
    | LBRACKET cmd SEMICOLON cmd RBRACKET { () }  
    | SKIP {()}

declare:
    VAR IDENT SEMICOLON cmd  { () }

assign:
    IDENT ASSIGN expr  { () }
	
expr :
  | PROC IDENT COLON cmd SEMICOLON   { () } (* Recursive procedure expression *)
  | expr MINUS expr      { () }
  | IDENT                { () }
  | NUM                  { () }  

%% (* trailer *)
