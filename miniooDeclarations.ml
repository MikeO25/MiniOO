(* File miniooDeclarations.ml *)
open Data;;

let get_location hp = match hp with
  | Heap([]) -> Object(0)
  (*| Heap([((Location(l), _) * _)]) -> Object(l+1)*)
  (*| Heap(_::rest) -> get_location(rest)*)


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
