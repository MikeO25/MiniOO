(* File helpers.ml *)
open Data;;
open Printf;;

let rec print_frame (fr: frame) = match fr with
  | Frame([]) -> ()
  | Frame((name, Object(i))::rest) -> printf "[name=`%s`, location=%d]\n" name i; print_frame (Frame(rest)); ()
  | Frame((name, NullLocation)::rest) -> printf "[name=`%s`, location=null]\n" name; print_frame (Frame(rest)) ; ()

let stack_is_empty (s: stack) = match s with
  | Stack([]) -> true
  | _ -> false

let rec print_stack (s: stack) = match s with
  | Stack([]) -> ()
  | Stack(fr::rest) -> (print_frame fr; print_stack (Stack(rest)); ())

let rec print_heap (h: heap) = match h with
  | Heap([]) -> ()
  | Heap(((Object(i), f), Value(IntVal(v)))::tl) -> printf "[loc=%d, field=`%s`, value=%d] \n" i f v; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(LocationVal(NullLocation)))::tl) -> printf "[loc=%d, field=`%s`, value=null] \n" i f ; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(LocationVal(Object(j))))::tl) -> printf "[loc=%d, field=`%s`, value=loc(%d)] \n" i f j; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(ClosureVal(_)))::tl) -> printf "[loc=%d, field=`%s`, value=`closure`] \n" i f; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(FieldVal(fd)))::tl) -> printf "[loc=%d, field=`%s`, value=@%s] \n" i f fd; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(_))::tl) -> printf "[loc=%d, field=`%s`, value=hi] \n" i f; print_heap (Heap(tl)); ()

let rec get_new_location (h: heap) = match h with 
  | Heap([]) -> Object(0)
  | Heap(((Object(i), _), _)::tl) -> let Object(j) = get_new_location (Heap(tl))
                                     in
                                     if j > i 
                                     then Object(j + 1)
                                     else Object(i + 1)


let rec get_location_from_frame (name: string) (f: frame) = match f with
  | Frame([]) -> NullLocation
  | Frame((n, l)::tl) -> if n = name then l  
                         else get_location_from_frame name (Frame(tl))


let rec get_location (name: string) (s: stack) = match s with
  | Stack([]) -> NullLocation
  | Stack(fr::tl) -> let res = get_location_from_frame name fr
                     in
                     if res = NullLocation 
                     then get_location name (Stack(tl))
                     else res 

let create_frame name (l: location) = Frame([(name, l)])

let add_frame (fr: frame) (s: stack) = match s with
  | Stack(s) -> Stack(fr::s)

(* 
   Given a location 'loc' and heap 'h'
   Create a value on the heap
*)
let allocate_val_on_heap (l: location) (h: heap) = match h with
  | Heap(hp) -> Heap(((l, "val"), Value(LocationVal(NullLocation)))::hp)

let assign_val_on_heap (l: location) (f: string) (res: tainted_value) (h: heap) = 
    match h, res with
  | Heap(hp), v -> let hp' = List.remove_assoc (l, f) hp in 
                   Heap(((l, f), v)::hp')
  
  | Heap(hp), _ -> Heap(((l, f), Value(LocationVal(NullLocation)))::hp)


let get_val_from_heap (l: location) (f: string) (h: heap) = match h with 
  | Heap(hp) -> if List.mem_assoc (l, f) hp
                then List.assoc (l, f) hp 
                else ValueError


let rec linearize_stack_into_frame (s: stack) = match s with
  | Stack([]) -> Frame([])
  | Stack(Frame(f)::rest) ->let fr' = linearize_stack_into_frame(Stack(rest)) in
                            (match fr' with Frame(f') -> Frame(f@f'))

let consolidate_for_closure (fr: frame) 
                            (st_closure: stack) 
                            (st_program: stack) = 
                            let st_closure' = add_frame fr st_closure in
                            let fr_closure'' = linearize_stack_into_frame st_closure' in 
                            add_frame fr_closure'' st_program


