open Ast;;
open Data;;
open MiniooDeclarations;;

(* pass in control and state *)
(*let rec eval conf s = match c with 
	| *)

(*let rec eval_conf c = match c with
	| ControlAndState(ControlCmd(c1), s) ->
	| ControlAndState(Block(c1), s)
	| FinalState -> 
	| ProgramError -> *)

let rec eval_cmd c s = match c, s with
	| Declare(name, c1), 
	  State(st, hp) -> let l = get_location hp 
	  								 in
	  								 let fr = create_frame name l
	  								 in
	  								 let st' = add_frame fr st
	  								 in
	  								 let hp' = allocate_val_on_heap l hp
	  								 in
	  								 ControlAndState(Block(c1), State(st', hp'))


and eval_expr e s = match e, s with
	| Num(i), 
	  State(st, hp) -> Value(IntVal(i))

(* define function equality / less_than *)
and eval_bool b s = match b with
	| BoolValue(b1) -> Bool(b1)
	| Equals(e1, e2) -> let rec v1 = eval_expr(e1)
						and v2 = eval_expr(e2)
						in Bool(v1 = v2)
	| LessThan(e1, e2) -> let rec v1 = eval_expr(e1)
						  and v2 = eval_expr(e2)
						  in Bool(v1 < v2)