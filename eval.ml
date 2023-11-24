open Ast;;
open Data;;
open MiniooDeclarations;;

(* pass in control and state *)
(*let rec eval conf s = match c with 
  | *)

let rec eval_final (c: conf) = match c with 
  | FinalState(State(s, h)) -> print_endline "Stack:";
                               print_stack s; 
                               print_endline "Heap:"; 
                               print_heap h; 
                               true 
  | ProgramError -> false

and eval_cmd (c: conf) = match c with
  (* Block *)
  | ControlAndState(
      Block(c1), s
      ) -> let res = eval_cmd (ControlAndState(Control(c1), s))
                               in 
                               (match res with 
                                | FinalState(
                                    State(Stack(top::rest), hp')) 
                                    -> FinalState(State(Stack(rest), hp'))
                                | ProgramError -> ProgramError)
  (* Declare *)
  | ControlAndState(
      Control(
        Declare(name, c1)), 
      State(st, hp)) ->  let loc = get_new_location hp 
                         in
                         let fr = create_frame name loc
                         in
                         let st' = add_frame fr st
                         in
                         let hp' = allocate_val_on_heap loc hp
                         in
                         eval_cmd (ControlAndState(Block(c1), State(st', hp')))
  (* Assign *)
  | ControlAndState(
      Control(    
        Assign(name, e)   
      ),  
      State(st, hp)

    ) -> let res = eval_expr e (State(st, hp))
                        in 
                        let loc = get_location name st
                        in
                        let hp' = assign_val_on_heap loc res hp
                        in
                        FinalState(State(st, hp'))

  (* If *)
  | ControlAndState(
    Control(
      If(b, c1, c2)), s) -> let res = eval_bool b s in
                            (match res with
                              | Bool(is_true) -> if is_true
                                             then eval_cmd (ControlAndState(Control(c1), s))
                                             else eval_cmd (ControlAndState(Control(c2), s))
                              | BoolError -> ProgramError)

  (* Sequence *)
  | ControlAndState(
      Control(
        Sequence(c1, c2)
      ), 
     State(st, hp)) ->
                      let res_c1 = eval_cmd (ControlAndState(Control(c1), State(st, hp)))
                      in 
                      (match res_c1 with
                        | FinalState(State(_, hp')) 
                          -> eval_cmd (ControlAndState(Control(c2), State(st, hp'))) 
                        | ProgramError -> ProgramError
                      )
  (* While *)
  | ControlAndState(
      Control(
        While(b, c1)
      ), s) -> let res = eval_bool b s
                   in
                   (match res with 
                    | Bool(is_true) -> if is_true then
                                       eval_cmd  (ControlAndState(
                                                    Control(Sequence(
                                                              c1, 
                                                              While(b, c1))), 
                                                    s))
                                       else FinalState(s)
                    | BoolError -> ProgramError 

                   ) 
  (* Procedure *)
  (*| ControlAndState(
      Control(
        ProcedureCall(e1, e2)
      ), 
     State(st, hp)) ->
                       let v1 = eval_expr e1 (State(st, hp))
                       in
                       ( match v1 with
                          Closure(name, c1, st') 
                          -> let loc = get_new_location hp 
                             in
                             let fr = create_frame name loc
                             in
                             let st'' = st' (add_frame fr st)
                             in
                             let hp' = allocate_val_on_heap loc hp
                             in
                             eval_cmd (ControlAndState(Block(c1), 
                                       State(st'', hp'))) 
                          _  -> ProgramError
                       )*)

and eval_expr e s = match e, s with
  | Num(i), _ -> Value(IntVal(i))
  
  | Ident(name), State(st, hp) -> let loc = get_location name st
                                  in
                                  get_val_from_heap loc "val" hp
  
  | Minus(e1, e2), s -> let v1 = eval_expr e1 s
                        and v2 = eval_expr e2 s
                        in 
                        (match v1, v2 with 
                        | Value(IntVal(i)), Value(IntVal(j)) -> Value(IntVal(i - j))
                        | _, _ -> ValueError)

  | Plus(e1, e2), s -> let v1 = eval_expr e1 s
                       and v2 = eval_expr e2 s
                       in 
                       (match v1, v2 with 
                       | Value(IntVal(i)), Value(IntVal(j)) -> Value(IntVal(i + j))
                       | _, _ -> ValueError)
  
  (*| ProcedureExpression(name, cmd), State(st, hp) 
                      -> Value(Closure(name, cmd, st))*)
  | _,_ -> Value(IntVal(0))

(* define function equality / less_than to check for errors
with pattern matching
  Error1, _ -> Error
  _, Error2 -> Error
*)
and eval_bool b s = match b with
  | BoolValue(b1) -> Bool(b1)
  
  | Equals(e1, e2) -> let v1 = eval_expr e1 s
                      and v2 = eval_expr e2 s
                      in 
                      (match v1, v2 with 
                      | Value(IntVal(i)), Value(IntVal(j)) -> Bool(i = j)
                      | _, _ -> BoolError)
  | LessThan(e1, e2) -> let v1 = eval_expr e1 s
                        and v2 = eval_expr e2 s
                        in 
                        (match v1, v2 with 
                        | Value(IntVal(i)), Value(IntVal(j)) -> Bool(i < j)
                        | _, _ -> BoolError)