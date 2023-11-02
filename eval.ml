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
    | Assign(name, e),
      State(Stack(st), Heap(hp))
      				-> let rec v = eval_expr(e)
      				   in FinalState(State(Stack(st), Heap(hp)))


and eval_expr e s = match e, s with
	| Num(i), 
	  State(Stack(st), Heap(hp)) -> Value(IntVal(i))

and eval_bool b s = match b with
	| BoolValue(b1) -> Bool(b1)
	| Equals(e1, e2) -> let rec v1 = eval_expr(e1)
						and v2 = eval_expr(e2)
						in Bool(v1 == v2)
	| LessThan(e1, e2) -> let rec v1 = eval_expr(e1)
						  and v2 = eval_expr(e2)
						  in Bool(v1 < v2)