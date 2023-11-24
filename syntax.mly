/* File syntax.mly */

%{ (* header *)

open Ast
open Check
open Eval
open Data


%} /* declarations */

%token EOL SEMICOLON COLON ASSIGN  /* lexer tokens */
%token EQUALS MINUS PLUS LBRACKET RBRACKET LPAREN RPAREN
%token VAR WHILE PROC SKIP TRUE FALSE IF THEN ELSE LESS_THAN NULL MALLOC ATOM /* reserved words */
%token DOT AT THREE_BARS
%token <string> IDENT
%token <int> NUM
%start prog                   /* the entry point */
%type <unit> prog  

%type <Ast.cmd> cmd
%type <Ast.boolean> boolean
%type <Ast.cmd> assign
%type <Ast.cmd> declare
%type <Ast.cmd> sequential_control
%type <Ast.expr> expr
%type <Ast.expr> field
%type <Ast.cmd> field_assignment
%type <Ast.cmd> recursive_procedure_call
%type <Ast.cmd> parallelism
%type <Ast.cmd> dynamic_object_allocation
%left MINUS /* lowest precedence  */

%% /* rules */

prog :
    c=cmd EOL  {
                if (check_cmd [] c) 
                then print_endline "Static check Success!" 
                else print_endline "Static check failed.";
                let start_conf = ControlAndState(Control(c), State(Stack([]), Heap([])))
                in
                let final_res =  eval_cmd start_conf
                in 
                if eval_final final_res
                then print_endline "Successfully Evaluated"
                else print_endline "Evaluation Failed :(";
                ()
            }

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
  | TRUE {BoolValue(true)}
  | FALSE {BoolValue(false)}
  | e1=expr EQUALS e2=expr {Equals(e1, e2)}
  | e1=expr LESS_THAN e2=expr {LessThan(e1, e2)}

(* command *)
sequential_control:
    | SKIP {Skip}
    
    | LBRACKET c1=cmd SEMICOLON c2=cmd RBRACKET 
           {Sequence(c1, c2)}
    
    | WHILE b=boolean c=cmd 
        {While(b, c)}
    
    | IF b=boolean THEN c1=cmd ELSE c2=cmd 
        {If(b, c1, c2)} 

(* command *)
parallelism:
    | LBRACKET c1=cmd THREE_BARS c2=cmd RBRACKET 
        {Parallel(c1, c2)}
    
    | ATOM LPAREN c=cmd RPAREN               
        {Atom(c)}

(* command *)
dynamic_object_allocation:
    MALLOC LPAREN i=IDENT RPAREN             {Malloc(i)}

(* command *)
recursive_procedure_call:
    e1=expr LPAREN e2=expr RPAREN 
    {ProcedureCall(e1, e2)}

(* command *)
declare:
    VAR i=IDENT SEMICOLON c=cmd  
        {Declare(i, c)}

(* command *)
assign:
    i=IDENT ASSIGN e=expr  {Assign(i, e)}
	
field:
    AT i=IDENT {Field(i)}

(* command *)
field_assignment:
    e1=expr DOT e2=expr ASSIGN e3=expr 
        {FieldAssign(e1, e2, e3)}

expr :
  | f=field {f}
  
  | PROC i=IDENT COLON c=cmd  
        {ProcedureExpression(i, c)} (* Recursive procedure expression *)
  
  | e1=expr MINUS e2=expr {Minus(e1, e2)}

  | e1=expr PLUS e2=expr {Plus(e1, e2)}

  | i=IDENT {Ident(i)}

  | n=NUM {Num(n)}

  | NULL  {Null} 

%% (* trailer *)
