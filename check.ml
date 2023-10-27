open Ast;;


let rec check_cmd vs c = match c with
	| Skip -> true
	| Sequence(c1, c2) -> (check_cmd vs c1) && (check_cmd vs c2)
	| While(b, c1) -> (check_bool vs b) && (check_cmd vs c1)
	| If(b, c1, c2) -> (check_bool vs b) && (check_cmd vs c1) && (check_cmd vs c2)
	| Parallel(c1, c2) -> (check_cmd vs c1) && (check_cmd vs c2)
	| Atom(c1) -> check_cmd vs c1
	| Malloc(v) -> List.mem v vs
	| ProcedureCall(e1, e2) -> (check_expr vs e1) && (check_expr vs e2)
	| Declare(s, c1) -> (check_cmd (s::vs) c1)
	| Assign(v, e) -> if (List.mem v vs) then (check_expr vs e) else (Printf.printf "`%s` not declared in scope!\n" v; false)
	| FieldAssign(e1, e2, e3) -> true (* TODO *)

and check_expr vs e = match e with
	| Minus(e1, e2) -> (check_expr vs e1) && (check_expr vs e2)
	| Ident(v) -> (List.mem v vs)
	| Num(i) -> true 
	| Null -> true
	| Field(s) -> true (* TODO *)
	| ProcedureExpression(s, c) -> true (* TODO *)

and check_bool vs b = match b with
	| BoolValue(b1) -> true
	| Equals(e1, e2) -> (check_expr vs e1) && (check_expr vs e2)
	| LessThan(e1, e2) -> (check_expr vs e1) && (check_expr vs e2)


