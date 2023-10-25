/* File syntax.mly */

%{ (* header *)

open Ast

%} /* declarations */

%token EOL SEMICOLON COLON ASSIGN  /* lexer tokens */
%token EQUALS MINUS LBRACKET RBRACKET LPAREN RPAREN
%token VAR WHILE PROC SKIP TRUE FALSE IF ELSE LESS_THAN NULL MALLOC ATOM /* reserved words */
%token DOT AT THREE_BARS
%token <string> IDENT
%token <int> NUM
%start prog                   /* the entry point */
%type <unit> prog  

%type <Ast.ast> cmd
%type <Ast.ast> boolean
%type <Ast.ast> assign
%type <Ast.ast> declare
%type <Ast.ast> sequential_control
%type <Ast.ast> expr
%type <Ast.ast> field
%type <Ast.ast> field_assignment
%type <Ast.ast> recursive_procedure_call
%type <Ast.ast> parallelism
%type <Ast.ast> dynamic_object_allocation
%left MINUS /* lowest precedence  */

%% /* rules */

prog :
    cmd EOL  { print_endline "Success!"; ()}

(* command *)
cmd :
  | c=declare { c }
  | c=assign  { c }
  | c=sequential_control { c }
  | c=field_assignment { c }
  | c=recursive_procedure_call { c }
  | c=parallelism  { c }
  | c=dynamic_object_allocation { c }

(* boolean *)
boolean:
  | TRUE {Node({label=Boolean}, [])}
  | FALSE {Node({label=Boolean}, [])}
  | e1=expr EQUALS e2=expr { Node({label=Boolean}, [e1; e2]) }
  | e1=expr LESS_THAN e2=expr { Node({label=Boolean}, [e1; e2]) }

(* command *)
sequential_control:
    | SKIP {
                Node({label=Command}, [])
           }
    
    | LBRACKET c1=cmd SEMICOLON c2=cmd RBRACKET 
           {
                Node({label=Command}, [c1; c2])
            }
    
    | WHILE b=boolean c=cmd 
        {Node({label=Command}, [b; c])}
    
    | IF b=boolean c1=cmd ELSE c2=cmd {Node({label=Command}, [b; c1; c2])} 

(* command *)
parallelism:
    | LBRACKET c1=cmd THREE_BARS c2=cmd RBRACKET 
        {Node({label=Command}, [c1; c2])}
    
    | ATOM LPAREN c=cmd RPAREN               
        {Node({label=Command}, [c])}

(* command *)
dynamic_object_allocation:
    MALLOC LPAREN IDENT RPAREN             {Node({label=Command}, [])}

(* command *)
recursive_procedure_call:
    e1=expr LPAREN e2=expr RPAREN {Node({label=Command}, [e1; e2])}

(* command *)
declare:
    VAR IDENT SEMICOLON c=cmd  {Node({label=Command},[c])}

(* command *)
assign:
    IDENT ASSIGN e=expr  
        {Node({label=Command}, [e]) }
	
field:
    AT IDENT {Node({label=Expression}, [])}

(* command *)
field_assignment:
    e1=expr DOT e2=expr ASSIGN e3=expr 
        {Node({label=Command}, [e1; e2; e3]) }

expr :
  | f=field {f}
  
  | PROC IDENT COLON c=cmd  
        { Node({label=Expression}, [c]) } (* Recursive procedure expression *)
  
  | e1=expr MINUS e2=expr      
    { Node({label=Expression}, [e1; e2])}

  | IDENT                
    {Node({label=Expression}, [])}

  | NUM                  
    {Node({label=Expression}, [])}

  | NULL                 
    {Node({label=Expression}, [])} 

%% (* trailer *)
