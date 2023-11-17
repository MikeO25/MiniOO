
(* The type of tokens. *)

type token = 
  | WHILE
  | VAR
  | TRUE
  | THREE_BARS
  | THEN
  | SKIP
  | SEMICOLON
  | RPAREN
  | RBRACKET
  | PROC
  | NUM of (int)
  | NULL
  | MINUS
  | MALLOC
  | LPAREN
  | LESS_THAN
  | LBRACKET
  | IF
  | IDENT of (string)
  | FALSE
  | EQUALS
  | EOL
  | ELSE
  | DOT
  | COLON
  | ATOM
  | AT
  | ASSIGN

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (unit)
