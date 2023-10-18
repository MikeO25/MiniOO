/* File syntax.mly */

%{ (* header *)
  
%} /* declarations */

%token EOL SEMICOLON COLON ASSIGN  /* lexer tokens */
%token EQUALS MINUS LBRACKET RBRACKET LPAREN RPAREN
%token VAR WHILE PROC SKIP TRUE FALSE IF ELSE LESS_THAN NULL MALLOC ATOM /* reserved words */
%token DOT AT THREE_BARS
%token <string> IDENT
%token <int> NUM
%start prog                   /* the entry point */
%type <unit> prog  

%type <unit> cmd
%type <unit> boolean
%type <unit> assign
%type <unit> declare
%type <unit> sequential_control
%type <unit> expr
%type <unit> field
%type <unit> field_assignment
%type <unit> recursive_procedure_call
%type <unit> parallelism
%type <unit> dynamic_object_allocation
%left MINUS /* lowest precedence  */

%% /* rules */

prog :
    cmd EOL  { print_endline "Success!"; () }
	
cmd :
  | declare { () }
  | assign  { () }
  | sequential_control { () }
  | field_assignment { () }
  | recursive_procedure_call { () }
  | parallelism  { () }
  | dynamic_object_allocation { () }

boolean:
  | TRUE { () }
  | FALSE { () }
  | expr EQUALS expr { () }
  | expr LESS_THAN expr { () }

sequential_control:
    | SKIP {()}
    | LBRACKET cmd SEMICOLON cmd RBRACKET { () }
    | WHILE boolean cmd { () }
    | IF boolean cmd ELSE cmd { () } 

parallelism:
    | LBRACKET cmd THREE_BARS cmd RBRACKET { () }
    | ATOM LPAREN cmd RPAREN               { () }

dynamic_object_allocation:
    MALLOC LPAREN IDENT RPAREN             { () }

recursive_procedure_call:
    expr LPAREN expr RPAREN { () }

declare:
    VAR IDENT SEMICOLON cmd  { () }

assign:
    IDENT ASSIGN expr  { () }
	
field:
    AT IDENT { () }

field_assignment:
    expr DOT expr ASSIGN expr { () }

expr :
  | field                 { () }
  | PROC IDENT COLON cmd  { () } (* Recursive procedure expression *)
  | expr MINUS expr      { () }
  | IDENT                { () }
  | NUM                  { () } 
  | NULL                 { () } 

%% (* trailer *)
