open Ast;;

type boolean = Bool of bool | RuntimeError

and obj = Object of int

and location = Object of obj | Null

and closure = (string * cmd * stack)

and value = Int of int | Field of string | Closure of closure | Location of location

and tainted_value = Value of value | RuntimeError

and frame = (string * int) list

and stack = frame list

and heap = ((obj * string) * int) list

and state = (stack * heap)

and control = Cmd of cmd | Block of cmd

and conf = ControlAndState of (control * state) | State of state | RuntimeError
