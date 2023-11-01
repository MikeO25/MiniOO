open Ast;;
open Data;;

let rec eval_cmd c s = match c, s with
	| Declare(name, c1), 
	  State(Stack(st), Heap(hp)) 
					-> let rec l = Object(0)
						and f = Frame([(name, l)])
					    and st' = f::st
					    and hp' = ((l, "val"), Value(LocationVal(Null)))::hp
					    in 
					    ControlAndState(Block(c1), 
					    				State(Stack(st'), Heap(hp')))


and eval_expr e s = match e, s with
	| Num(i), 
	  State(Stack(st), Heap(hp)) -> Value(IntVal(i))

	(*| Minus(e1, e2) -> true*)
	(*| Ident(v) -> true*)
	(*| Null -> true *)
	(*| Field(f) -> true*)
	(*| ProcedureExpression(v, c) -> true*)

and eval_bool b s = match b with
	| BoolValue(b1) -> true
	| Equals(e1, e2) -> true
	| LessThan(e1, e2) -> true