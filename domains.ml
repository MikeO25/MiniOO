open Ast

type boolean = Bool of bool | BoolError of string
and location = Object of int | NullLocation
and closure = Closure of string * cmd * stack

and value =
  | IntVal of int
  | FieldVal of string
  | ClosureVal of closure
  | LocationVal of location

and tainted_value = Value of value | ValueError of string
and frame = Frame of (string * location) list
and stack = Stack of frame list
and heap = Heap of ((location * string) * tainted_value) list
and state = State of stack * heap
and control = Control of cmd | Block of cmd

and conf =
  | ControlAndState of (control * state)
  | FinalState of state
  | ProgramError of string
