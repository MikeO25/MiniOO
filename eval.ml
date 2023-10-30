let rec eval_cmd c s: state = match cmd with
	| Skip -> true
	| Sequence(c1, c2) -> true
	| While(b, c1) -> true
	| If(b, c1, c2) -> true
	| Parallel(c1, c2) -> true
	| Atom(c1) -> true
	| Malloc(v) -> true
	| ProcedureCall(e1, e2) -> true
	| Declare(s, c1) -> true
	| Assign(v, e) -> true

and eval_expr e s: state = match e with
	| Minus(e1, e2) -> true
	| Ident(v) -> true
	| Num(i) -> true 
	| Null -> true
	| Field(f) -> true 
	| ProcedureExpression(v, c) -> true

and eval_bool b s: state = match b with
	| BoolValue(b1) -> true
	| Equals(e1, e2) -> true
	| LessThan(e1, e2) -> true