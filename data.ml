open Ast;;

type boolean = Bool of bool | RuntimeError

and obj = Object of int

and location = Object of obj | Null

and closure = (string * cmd * stack)

and value = I of int | F of string | C of closure | L of location

and tainted_value = Val of value | RuntimeError

and frame = (string * int) list

and stack = frame list

and heap = ((int * string) * int) list

and state = (stack * heap)

and control = Cmd of cmd | Block of cmd

and conf = (control * state) | state | RuntimeError
