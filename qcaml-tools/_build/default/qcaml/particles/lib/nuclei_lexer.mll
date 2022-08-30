(* Lexer
 *    
 *     =nuclei_lexer.mll= contains the description of the lexemes used in
 *     an xyz file. *)
    

(* [[file:~/QCaml/particles/nuclei.org::*Lexer][Lexer:1]] *)
{
open Xyz_parser
}

let eol = ['\n']
let white = [' ' '\t']+
let word = [^' ' '\t' '\n']+
let letter = ['A'-'Z' 'a'-'z']
let integer = ['0'-'9']+
let real = '-'? (integer '.' integer | integer '.' | '.' integer) (['e' 'E'] ('+'|'-')? integer)?


rule read_all = parse
  | eof            { EOF }
  | eol            { EOL }
  | white   as w   { SPACE w }
  | integer as i   { INTEGER (int_of_string i) }
  | real    as f   { FLOAT (float_of_string f) }
  | word    as w   { WORD w }


{
(* DEBUG
 let () =
   let ic = open_in "h2o.xyz" in
   let lexbuf = Lexing.from_channel ic in
   while true do
     let s =
      match read_all lexbuf with
      | EOL -> "EOL"
      | SPACE w -> "SPACE("^w^")"
      | INTEGER i -> "INTEGER("^(string_of_int i)^")"
      | FLOAT f -> "FLOAT("^(string_of_float f)^")"
      | WORD w -> "WORD("^w^")"
      | EOF -> "EOF"
     in
     print_endline s
   done;
*)
}
(* Lexer:1 ends here *)
