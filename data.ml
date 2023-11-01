open Ast;;

type boolean = Bool of bool | RuntimeError

and location = Object of int | Null

and closure = (string * cmd * stack)

and value = Int of int | Field of string | Closure of closure | Location of location

and tainted_value = Value of value | RuntimeError

and env = Env of (string * location) list

and call = Call of (env * stack)

and frame = Frame of (string * location) list

and stack = Stack of frame list

and heap = Heap of ((location * string) * tainted_value) list

and state = State of stack * heap

and control = Cmd of cmd | Block of cmd

and conf = ControlAndState of (control * state) | OnlyState of state | RuntimeError
