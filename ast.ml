type expr = 
    | Minus of expr * expr
    | Plus of expr * expr
    | Ident of string
    | Num of int
    | Null
    | Field of string
    | FieldExpression of expr * expr
    | ProcedureExpression of string * cmd 

and boolean =
    | BoolValue of bool
    | Equals of expr * expr
    | LessThan of expr * expr

and cmd = 
    | Skip
    | Sequence of cmd * cmd
    | While of boolean * cmd
    | If of boolean * cmd * cmd 
    | Parallel of cmd * cmd
    | Atom of cmd 
    | Malloc of string
    | ProcedureCall of expr * expr
    | Declare of string * cmd 
    | Assign of string * expr
    | FieldAssign of expr * expr * expr

let rec print_cmd (c: cmd) (ts: int) = match c with 
    | Skip -> ""
    | Sequence(c1, c2) -> ""
    | While(b, c1) -> ""
    | If (b, c1, c2) -> ""
    | Parallel(c1, c2) -> ""
    | Atom(c1) -> ""
    | Malloc(name) -> ""
    | ProcedureCall(e1, e2) -> ""
    | Declare(name, c1) -> ""
    | Assign(name, e) -> ""
    | FieldAssign(e1, e2, e3) -> ""





