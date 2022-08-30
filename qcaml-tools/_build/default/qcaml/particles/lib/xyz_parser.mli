type token =
  | EOL
  | SPACE of (string)
  | WORD of (string)
  | INTEGER of (int)
  | FLOAT of (float)
  | EOF

val input :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Xyz_ast.xyz_file
