(* 
frame: list of ids -> location on the heap
*)
type frame = (string * int) list;;

(*
ftack: list of frames
*)
type stack = frame list;;

type heap = ((int * string) * int) list;;

type state = (stack * heap)
