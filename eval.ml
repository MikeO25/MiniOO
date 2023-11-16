open Ast;;
open Data;;
open MiniooDeclarations;;

(* pass in control and state *)
(*let rec eval conf s = match c with 
	| *)

let rec eval_conf (c: conf) = match c with
	| ControlAndState(Control(curr_cmd), curr_state) -> eval_conf (eval_cmd curr_cmd curr_state)
	| ControlAndState(Block(curr_cmd), curr_state) -> eval_conf (eval_cmd curr_cmd curr_state)
	| FinalState(State(s, h)) -> print_heap h; true 
	| ProgramError -> false

and eval_cmd (c: cmd) (s: state) = match c, s with
	| Declare(name, c1), 
	  State(st, hp) ->   let loc = get_new_location hp 
                       in
                       let fr = create_frame name loc
                       in
                       let st' = add_frame fr st
                       in
                       let hp' = allocate_val_on_heap loc hp
                       in
                       ControlAndState(Block(c1), State(st', hp'))
  | Assign(name, e),
    State(st, hp) -> let res = eval_expr e (State(st, hp))
                     in 
                     let loc = get_location name st
                     in
                     let hp' = assign_val_on_heap loc res hp
                     in
                     FinalState(State(st, hp'))

  | Sequence(c1, c2), 
  	State(st, hp) -> let result_conf = eval_cmd c1 (State(st, hp))
										 in
										 match result_conf with
										 | ControlAndState(Control(c1'), State(st', hp'))
										 		-> eval_cmd (Sequence(c1', c2)) (State(st', hp'))
										 | ControlAndState(Block(c1'), State(st', hp'))
										 		-> eval_cmd (Sequence(c1', c2)) (State(st', hp'))
										 | FinalState(State(st', hp')) 
										 		-> eval_cmd c2 (State(st', hp'))
										 | ProgramError -> ProgramError


and eval_expr e s = match e, s with
	| Num(i), _ -> Value(IntVal(i))
	| Ident(name), State(st, hp) -> let loc = get_location name st
																	in
																	get_val_from_heap loc "val" hp
	| Minus(e1, e2), s -> let v1 = eval_expr e1 s
											  and v2 = eval_expr e2 s
											  in 
											  match v1, v2 with 
											  | Value(IntVal(i)), Value(IntVal(j)) -> Value(IntVal(i - j))
											  | _, _ -> ValueError
	| _,_ -> Value(IntVal(0))

(* define function equality / less_than to check for errors
with pattern matching
	Error1, _ -> Error
	_, Error2 -> Error
*)
and eval_bool b s = match b with
	| BoolValue(b1) -> Bool(b1)
	| Equals(e1, e2) -> let rec v1 = eval_expr(e1)
						and v2 = eval_expr(e2)
						in Bool(v1 = v2)
	| LessThan(e1, e2) -> let rec v1 = eval_expr(e1)
						  and v2 = eval_expr(e2)
						  in Bool(v1 < v2)