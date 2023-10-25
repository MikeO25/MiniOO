(* File minioo.ml *)
(* declare file and pass it in *)
open Parsing;;

try
  let lexbuf = Lexing.from_channel stdin in
  while true do
    try
      Syntax.prog Lexer.token lexbuf
    with Parse_error ->
      (print_string "Syntax error ..." ; print_newline ()) ;
    clear_parser ()
  done
with Lexer.Eof ->
  ()
;;
