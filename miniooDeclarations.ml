(* File miniooDeclarations.ml *)
open Data;;

let get_new_location (h: heap) = Object(0)

let create_frame name (l: location) = Frame([(name, l)])

let add_frame (fr: frame) (s: stack) = match s with
  | Stack(s) -> Stack(fr::s)

let allocate_val_on_heap (l: location) (h: heap) = match h with
  | Heap(hp) -> Heap(((l, "val"), Value(LocationVal(Null)))::hp)


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
