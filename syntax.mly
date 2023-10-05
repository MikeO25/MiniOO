/* File syntax.mly */

%{ (* header *)
  
%} /* declarations */

%token EOL SEMICOLON COLON ASSIGN  /* lexer tokens */
%token EQUALS MINUS LBRACKET RBRACKET
%token VAR WHILE PROC SKIP TRUE FALSE IF ELSE LESS_THAN /* reserved words */
%token <string> IDENT
%token <int> NUM
%start prog                   /* the entry point */
%type <unit> prog  
/* the header is copied in calculatorMENHIR.ml but
not is calculatorMENHIR.mli where typeProg must be
qualified by the module where the type is declared */
%type <unit> cmds
%type <unit> cmd
%type <unit> boolean
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
  | expr LESS_THAN expr { () }

sequential_control:
    | SKIP {()}
    | LBRACKET declare RBRACKET { () }
    | LBRACKET cmd SEMICOLON cmd RBRACKET { () }
    | WHILE boolean cmd { () }
    | IF boolean cmd ELSE cmd { () } 

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
