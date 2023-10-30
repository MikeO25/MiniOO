open Ast;;
open Data;;

let rec eval_cmd c s = match c, s with
	| Declare(s, c1), State(st, hp) 
							->  let rec l = Object(0)
							    and f = Frame([(s, l)])
					            and st' = f::st
					            and hp' = ((l, "val"), Value(Location(Null)))::hp
					            in (Block(c1), State(st', hp'))

and eval_expr e s = match e with
	| Minus(e1, e2) -> true
	| Ident(v) -> true
	| Num(i) -> true 
	| Null -> true
	| Field(f) -> true 
	| ProcedureExpression(v, c) -> true

and eval_bool b s = match b with
	| BoolValue(b1) -> true
	| Equals(e1, e2) -> true
	| LessThan(e1, e2) -> true