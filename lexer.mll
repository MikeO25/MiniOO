(* File lexer.mll *)
{
open Syntax  (* Type token defined in CalculatorMENHIR.mli *)
exception Eof 
}
rule token = parse
    [' ' '\t'] { token lexbuf } (* skip blanks and tabs *)
  | ['\n' ]    { EOL }
  | "proc"     { PROC }
  | "while"    { WHILE }
  | "if"       { IF }
  | "else"     { ELSE }
  | "skip"     { SKIP }
  | "var"      { VAR }
  | "true"     { TRUE }
  | "false"    { FALSE }
  | (['a'-'z'] | ['A'-'Z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt
               { IDENT idt }
  | ['0'-'9']+ as num
               { NUM (int_of_string num) }
  | ';'        { SEMICOLON }
  | ':'        { COLON     }
  | "=="       { EQUALS    }
  | '<'        { LESS_THAN }
  | '='        { ASSIGN }
  | '-'        { MINUS }
  | '{'        { LBRACKET }
  | '}'        { RBRACKET }
  | eof        { raise Eof }
  | _ as c { failwith (Printf.sprintf "unexpected character: %C" c)}

