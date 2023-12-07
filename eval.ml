open Ast
open Domains
open Helpers
open Printf

(* pass in control and state *)
(*let rec eval conf s = match c with
  | *)

let rec eval_final (c : conf) =
  match c with
  | FinalState (State (s, h)) ->
      print_endline "\nFinal Stack";
      print_endline "===========";
      if stack_is_empty s then print_endline "empty\n" else print_stack s;
      print_endline "Final Heap";
      print_endline "==========";
      print_heap h;
      true
  | ProgramError _ -> false

and eval_cmd (c : conf) =
  match c with
  (* Block *)
  | ControlAndState (Block c1, s) -> (
      let res = eval_cmd (ControlAndState (Control c1, s)) in
      match res with
      | FinalState (State (Stack (top :: rest), hp')) ->
          print_endline "<= Popping frame off stack:";
          print_frame top;
          FinalState (State (Stack rest, hp'))
      | ProgramError p_e -> ProgramError p_e)
  (* Declare *)
  | ControlAndState (Control (Declare (name, c1)), State (st, hp)) ->
      let loc = get_new_location hp in
      let fr = create_frame name loc in
      let st' = add_frame fr st in
      let hp' = allocate_val_on_heap loc hp in
      print_endline "=> Popping frame onto stack:";
      print_frame fr;
      eval_cmd (ControlAndState (Block c1, State (st', hp')))
  (* Assign *)
  | ControlAndState (Control (Assign (name, e)), State (st, hp)) -> (
      let res = eval_expr e (State (st, hp)) in
      match res with
      | Value v ->
          let loc = get_location name st in
          let hp' = assign_val_on_heap loc "val" (Value v) hp in
          FinalState (State (st, hp'))
      | ValueError v_e -> ProgramError v_e
      (* FieldAssign *))
  | ControlAndState (Control (FieldAssign (e1, e2, e3)), State (st, hp)) -> (
      let v1 = eval_expr e1 (State (st, hp))
      and v2 = eval_expr e2 (State (st, hp))
      and v3 = eval_expr e3 (State (st, hp)) in
      match (v1, v2, v3) with
      | Value (LocationVal NullLocation), _, _ ->
          ProgramError "cannot assign a field to a null location."
      | Value (LocationVal loc), Value (FieldVal f), Value v ->
          let hp' = assign_val_on_heap loc f (Value v) hp in
          FinalState (State (st, hp'))
      | _, _, _ -> ProgramError "error in field assignment.")
  (* If *)
  | ControlAndState (Control (If (b, c1, c2)), s) -> (
      let res = eval_bool b s in
      match res with
      | Bool is_true ->
          if is_true then eval_cmd (ControlAndState (Control c1, s))
          else eval_cmd (ControlAndState (Control c2, s))
      | BoolError b_e -> ProgramError b_e)
  (* Skip *)
  | ControlAndState (Control Skip, s) -> FinalState s
  (* Malloc *)
  | ControlAndState (Control (Malloc name), State (st, hp)) ->
      let loc = get_location name st in
      let m_loc = get_new_location hp in
      let hp' = assign_val_on_heap loc "val" (Value (LocationVal m_loc)) hp in
      FinalState (State (st, hp'))
  (* Sequence *)
  | ControlAndState (Control (Sequence (c1, c2)), State (st, hp)) -> (
      let res_c1 = eval_cmd (ControlAndState (Control c1, State (st, hp))) in
      match res_c1 with
      | FinalState (State (_, hp')) ->
          eval_cmd (ControlAndState (Control c2, State (st, hp')))
      | ProgramError p_e -> ProgramError p_e)
  (* While *)
  | ControlAndState (Control (While (b, c1)), s) -> (
      let res = eval_bool b s in
      match res with
      | Bool is_true ->
          if is_true then
            eval_cmd
              (ControlAndState (Control (Sequence (c1, While (b, c1))), s))
          else FinalState s
      | BoolError b_e -> ProgramError b_e)
  (* Procedure *)
  | ControlAndState (Control (ProcedureCall (e1, e2)), State (st, hp)) -> (
      let v1 = eval_expr e1 (State (st, hp))
      and v2 = eval_expr e2 (State (st, hp)) in
      match (v1, v2) with
      | Value (ClosureVal (Closure (name, c1, st'))), ValueError v_e ->
          ProgramError v_e
      | Value (ClosureVal (Closure (name, c1, st'))), v2 ->
          let loc = get_new_location hp in
          let fr = create_frame name loc in
          let st'' = consolidate_for_closure fr st' st in
          let hp' = allocate_val_on_heap loc hp in
          let hp'' = assign_val_on_heap loc "val" v2 hp' in
          eval_cmd (ControlAndState (Block c1, State (st'', hp'')))
      | _, _ -> ProgramError "failed to execute procedure call.")
  (* Atom *)
  | ControlAndState (Control (Atom c1), s) ->
      eval_cmd (ControlAndState (Control c1, s))
  (* Parallelism *)
  | ControlAndState (Control (Parallel (c1, c2)), s) ->
      Random.self_init ();
      let i = Random.int 2 in
      if i = 0 then eval_cmd (ControlAndState (Control (Sequence (c1, c2)), s))
      else eval_cmd (ControlAndState (Control (Sequence (c2, c1)), s))

and eval_expr e s =
  match (e, s) with
  | Num i, _ -> Value (IntVal i)
  | Field name, _ -> Value (FieldVal name)
  | Ident name, State (st, hp) ->
      let loc = get_location name st in
      get_val_from_heap loc "val" hp
  | FieldExpression (e1, e2), State (st, hp) -> (
      let v1 = eval_expr e1 s and v2 = eval_expr e2 s in
      match (v1, v2) with
      | Value (LocationVal loc), Value (FieldVal f) ->
          get_val_from_heap loc f hp
      | Value (LocationVal loc), ValueError v_e -> ValueError v_e
      | _, _ -> ValueError "ValueError - failed to evaluate field expression.")
  | Minus (e1, e2), s -> (
      let v1 = eval_expr e1 s and v2 = eval_expr e2 s in
      match (v1, v2) with
      | Value (IntVal i), Value (IntVal j) -> Value (IntVal (i - j))
      | _, _ -> ValueError "ValueError - failed to evaluate minus expression.")
  | Plus (e1, e2), s -> (
      let v1 = eval_expr e1 s and v2 = eval_expr e2 s in
      match (v1, v2) with
      | Value (IntVal i), Value (IntVal j) -> Value (IntVal (i + j))
      | _, _ -> ValueError "ValueError - failed to evaluate plus expression.")
  | ProcedureExpression (name, cmd), State (st, _) ->
      Value (ClosureVal (Closure (name, cmd, st)))
  | Null, s -> Value (LocationVal NullLocation)

and eval_bool b s =
  match b with
  | BoolValue b1 -> Bool b1
  | Equals (e1, e2) -> (
      let v1 = eval_expr e1 s and v2 = eval_expr e2 s in
      match (v1, v2) with
      | Value (IntVal i), Value (IntVal j) -> Bool (i = j)
      | Value (ClosureVal i), Value (ClosureVal j) -> Bool (i = j)
      | Value (LocationVal i), Value (LocationVal j) -> Bool (i = j)
      | Value (FieldVal i), Value (FieldVal j) -> Bool (i = j)
      | _, _ ->
          BoolError
            "BoolError - for ==, unable to compare two variables of different \
             types.")
  | LessThan (e1, e2) -> (
      let v1 = eval_expr e1 s and v2 = eval_expr e2 s in
      match (v1, v2) with
      | Value (IntVal i), Value (IntVal j) -> Bool (i < j)
      | _, _ ->
          BoolError
            "BoolError - for < one or both of the variables being compared is \
             not a number.")
