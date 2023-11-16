(* File helpers.ml *)
open Data;;
open Printf;;

let rec print_heap (h: heap) = match h with
  | Heap([]) -> ()
  | Heap(((Object(i), f), Value(IntVal(v)))::tl) -> printf "[loc=%d, field=`%s`, value=%d] \n" i f v; print_heap (Heap(tl)); ()
  | Heap(((Object(i), f), Value(LocationVal(v)))::tl) -> printf "[loc=%d, field=`%s`, value=null] \n" i f; print_heap (Heap(tl)); ()

let rec get_new_location (h: heap) = match h with 
  | Heap([]) -> Object(0)
  | Heap(((Object(i), _), _)::tl) -> let Object(j) = get_new_location (Heap(tl))
                                     in
                                     if j > i 
                                     then Object(j + 1)
                                     else Object(i + 1)



let rec get_location (name: string) (s: stack) = match s with
  | Stack([]) -> Null
  | Stack(Frame([(n, l)])::tl) -> if n = name then l  
                                  else get_location name (Stack(tl))

let create_frame name (l: location) = Frame([(name, l)])

let add_frame (fr: frame) (s: stack) = match s with
  | Stack(s) -> Stack(fr::s)

(* 
   Given a location 'loc' and heap 'h'
   Create a value on the heap
*)
let allocate_val_on_heap (l: location) (h: heap) = match h with
  | Heap(hp) -> Heap(((l, "val"), Value(LocationVal(Null)))::hp)

let assign_val_on_heap (l: location) (res: tainted_value) (h: heap) = 
    match h, res with
  | Heap(hp), Value(IntVal(i)) -> let hp' = List.remove_assoc (l, "val") hp
                                  in 
                                  Heap(((l, "val"), Value(IntVal(i)))::hp')

  | Heap(hp), _ -> Heap(((l, "val"), Value(LocationVal(Null)))::hp)


let get_val_from_heap (l: location) (f: string) (h: heap) = match h with 
  | Heap(hp) -> if List.mem_assoc (l, f) hp
                then List.assoc (l, f) hp 
                else ValueError

type symbTable = (string * int) list ;;

let sb = ref([] : symbTable) ;;

let getvalue x =
   if (List.mem_assoc x !sb) then 
     (List.assoc x !sb)
   else
     0;;

let rec except x l = match l with
  []   -> []
| h::t -> if (h = x) then t
            else h::(except x t)

let setvalue x v =
  (print_string (x ^ " = "); print_int (v);
   print_string ";\n"; flush stdout;
   if (List.mem_assoc x !sb) then
     sb := (x, v) :: (except (x, (List.assoc x !sb)) !sb)
   else
     sb := (x, v) :: !sb 
  );;
