type expr = 
	| Minus of expr * expr
	| Ident of string
	| Num of int
	| Null
	| Field of string
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

type ast_node = Expr of expr | Bool of boolean | Cmd of cmd;;





