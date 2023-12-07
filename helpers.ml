(* File helpers.ml *)
open Domains
open Printf
open Ast

let rec print_frame (fr : frame) =
  match fr with
  | Frame [] -> ()
  | Frame ((name, Object i) :: rest) ->
      printf "[name=`%s`, location=%d]\n" name i;
      print_frame (Frame rest);
      ()
  | Frame ((name, NullLocation) :: rest) ->
      printf "[name=`%s`, location=null]\n" name;
      print_frame (Frame rest);
      ()

let stack_is_empty (s : stack) = match s with Stack [] -> true | _ -> false

let rec print_stack (s : stack) =
  match s with
  | Stack [] -> ()
  | Stack (fr :: rest) ->
      print_frame fr;
      print_stack (Stack rest);
      ()

let rec print_heap (h : heap) =
  match h with
  | Heap [] -> ()
  | Heap (((Object i, f), Value (IntVal v)) :: tl) ->
      printf "[loc=%d, field=`%s`, value=%d] \n" i f v;
      print_heap (Heap tl);
      ()
  | Heap (((Object i, f), Value (LocationVal NullLocation)) :: tl) ->
      printf "[loc=%d, field=`%s`, value=null] \n" i f;
      print_heap (Heap tl);
      ()
  | Heap (((Object i, f), Value (LocationVal (Object j))) :: tl) ->
      printf "[loc=%d, field=`%s`, value=loc(%d)] \n" i f j;
      print_heap (Heap tl);
      ()
  | Heap (((Object i, f), Value (ClosureVal _)) :: tl) ->
      printf "[loc=%d, field=`%s`, value=`closure`] \n" i f;
      print_heap (Heap tl);
      ()
  | Heap (((Object i, f), Value (FieldVal fd)) :: tl) ->
      printf "[loc=%d, field=`%s`, value=@%s] \n" i f fd;
      print_heap (Heap tl);
      ()
  | Heap (((Object i, f), Value _) :: tl) ->
      printf "[loc=%d, field=`%s`, value=hi] \n" i f;
      print_heap (Heap tl);
      ()

let rec get_new_location (h : heap) =
  match h with
  | Heap [] -> Object 0
  | Heap (((Object i, _), _) :: tl) ->
      let (Object j) = get_new_location (Heap tl) in
      if j > i then Object (j + 1) else Object (i + 1)

let rec get_location_from_frame (name : string) (f : frame) =
  match f with
  | Frame [] -> NullLocation
  | Frame ((n, l) :: tl) ->
      if n = name then l else get_location_from_frame name (Frame tl)

let rec get_location (name : string) (s : stack) =
  match s with
  | Stack [] -> NullLocation
  | Stack (fr :: tl) ->
      let res = get_location_from_frame name fr in
      if res = NullLocation then get_location name (Stack tl) else res

let create_frame name (l : location) = Frame [ (name, l) ]

let add_frame (fr : frame) (s : stack) =
  match s with Stack s -> Stack (fr :: s)

(*
    Given a location 'loc' and heap 'h'
    Create a value on the heap
*)
let allocate_val_on_heap (l : location) (h : heap) =
  match h with
  | Heap hp -> Heap (((l, "val"), Value (LocationVal NullLocation)) :: hp)

let assign_val_on_heap (l : location) (f : string) (res : tainted_value)
    (h : heap) =
  match (h, res) with
  | Heap hp, v ->
      let hp' = List.remove_assoc (l, f) hp in
      Heap (((l, f), v) :: hp')
  | Heap hp, _ -> Heap (((l, f), Value (LocationVal NullLocation)) :: hp)

let get_val_from_heap (l : location) (f : string) (h : heap) =
  match h with
  | Heap hp ->
      if List.mem_assoc (l, f) hp then List.assoc (l, f) hp
      else ValueError "ValueError - unable to find value on heap"

let rec linearize_stack_into_frame (s : stack) =
  match s with
  | Stack [] -> Frame []
  | Stack (Frame f :: rest) -> (
      let fr' = linearize_stack_into_frame (Stack rest) in
      match fr' with Frame f' -> Frame (f @ f'))

let consolidate_for_closure (fr : frame) (st_closure : stack)
    (st_program : stack) =
  let st_closure' = add_frame fr st_closure in
  let fr_closure'' = linearize_stack_into_frame st_closure' in
  add_frame fr_closure'' st_program

let join l = List.filter (fun s -> s <> "") l |> String.concat " "
let rec create_spaces n = if n == 0 then [] else " " :: create_spaces (n - 1)

let rec print_cmd (c : cmd) (ts : int) =
  match c with
  | Skip ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(skip)\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | Sequence (c1, c2) ->
      let spaces = create_spaces ts in
      let spaces_and_seq = spaces @ [ "(sequence\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_seq in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_cmd c1 (ts + 1);
      print_cmd c1 (ts + 1);
      printf "%s" sl
  | While (b, c1) ->
      let spaces = create_spaces ts in
      let spaces_and_while = spaces @ [ "(while\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_while in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_bool b (ts + 1);
      print_cmd c1 (ts + 1);
      printf "%s" sl
  | If (b, c1, c2) ->
      let spaces = create_spaces ts in
      let spaces_and_if = spaces @ [ "(if\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_if in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_bool b (ts + 1);
      print_cmd c1 (ts + 1);
      print_cmd c2 (ts + 1);
      printf "%s" sl
  | Parallel (c1, c2) ->
      let spaces = create_spaces ts in
      let spaces_and_parallel = spaces @ [ "(parallel\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_parallel in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_cmd c1 (ts + 1);
      print_cmd c1 (ts + 1);
      printf "%s" sl
  | Atom c1 ->
      let spaces = create_spaces ts in
      let spaces_and_atom = spaces @ [ "(atom\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_atom in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_cmd c1 (ts + 1);
      printf "%s" sl
  | Malloc name ->
      let spaces = create_spaces ts in
      let spaces_and_declare =
        spaces @ [ "(malloc (ident =" ] @ [ name ] @ [ ")\n" ]
      in
      let sr = join spaces_and_declare in
      printf "%s" sr
  | ProcedureCall (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_proc_call = spaces @ [ "(procedure-call\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_proc_call in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl
  | Declare (name, c1) ->
      let spaces = create_spaces ts in
      let spaces_and_declare =
        spaces @ [ "(declare (ident =" ] @ [ name ] @ [ ")\n" ]
      in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_declare in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_cmd c1 (ts + 1);
      printf "%s" sl
  | Assign (name, e) ->
      let spaces = create_spaces ts in
      let spaces_and_assign =
        spaces @ [ "(assign (ident =" ] @ [ name ] @ [ ")\n" ]
      in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_assign in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e (ts + 1);
      printf "%s" sl
  | FieldAssign (e1, e2, e3) ->
      let spaces = create_spaces ts in
      let spaces_and_field_assign = spaces @ [ "(field-assign\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_field_assign in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      print_expr e3 (ts + 1);
      printf "%s" sl

and print_expr (e : expr) (ts : int) =
  match e with
  | Minus (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_minus = spaces @ [ "(minus\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_minus in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl
  | Plus (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_plus = spaces @ [ "(plus\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_plus in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl
  | Ident name ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(ident =" ] @ [ name ] @ [ ")\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | Num i ->
      let spaces = create_spaces ts in
      let int_str = string_of_int i in
      let spaces_and_str = spaces @ [ "(num =" ] @ [ int_str ] @ [ ")\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | Null ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(null)\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | Field f ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(field =" ] @ [ f ] @ [ ")\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | FieldExpression (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_field_expr = spaces @ [ "(field-expr\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_field_expr in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl
  | ProcedureExpression (name, c) ->
      let spaces = create_spaces ts in
      let spaces_and_proc_expr =
        spaces @ [ "(procedure-expr (ident = " ] @ [ name ] @ [ ")\n" ]
      in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_proc_expr in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_cmd c (ts + 1);
      printf "%s" sl

and print_bool (b : boolean) (ts : int) =
  match b with
  | BoolValue b1 ->
      let spaces = create_spaces ts in
      let bool_str = if b1 then "true" else "false" in
      let spaces_and_str = spaces @ [ "(bool =" ] @ [ bool_str ] @ [ ")\n" ] in
      let s = join spaces_and_str in
      printf "%s" s
  | Equals (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(equals\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_str in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl
  | LessThan (e1, e2) ->
      let spaces = create_spaces ts in
      let spaces_and_str = spaces @ [ "(less-than\n" ] in
      let spaces_and_lparen = spaces @ [ ")\n" ] in
      let sr = join spaces_and_str in
      let sl = join spaces_and_lparen in
      printf "%s" sr;
      print_expr e1 (ts + 1);
      print_expr e2 (ts + 1);
      printf "%s" sl

let get_error (c : conf) = match c with ProgramError s -> s | _ -> "None"
