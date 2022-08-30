type token =
  | EOL
  | SPACE of (string)
  | WORD of (string)
  | INTEGER of (int)
  | FLOAT of (float)
  | EOF

open Parsing;;
let _ = parse_error;;
# 2 "qcaml/particles/lib/xyz_parser.mly"
open Common

let make_angstrom x y z =
  Coordinate.(make_angstrom {
    x ; y ; z
  })

let output_of f x y z =
  let a = make_angstrom x y z in
  fun e ->
  {
    Xyz_ast.
    element = f e;
    coord = a ;
  }

let output_of_string = output_of Element.of_string
let output_of_int    = output_of Element.of_int

# 32 "qcaml/particles/lib/xyz_parser.ml"
let yytransl_const = [|
  257 (* EOL *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  258 (* SPACE *);
  259 (* WORD *);
  260 (* INTEGER *);
  261 (* FLOAT *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\003\000\006\000\006\000\
\006\000\006\000\005\000\005\000\004\000\004\000\007\000\007\000\
\007\000\007\000\007\000\007\000\007\000\007\000\007\000\000\000"

let yylen = "\002\000\
\003\000\002\000\003\000\003\000\004\000\002\000\001\000\001\000\
\001\000\001\000\000\000\002\000\002\000\002\000\000\000\009\000\
\010\000\009\000\010\000\010\000\011\000\010\000\011\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\024\000\011\000\000\000\002\000\
\000\000\015\000\000\000\004\000\000\000\003\000\001\000\000\000\
\006\000\008\000\007\000\010\000\009\000\012\000\005\000\013\000\
\000\000\000\000\000\000\014\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\016\000\000\000\
\018\000\000\000\020\000\000\000\022\000\000\000\017\000\019\000\
\021\000\023\000"

let yydgoto = "\002\000\
\005\000\006\000\010\000\015\000\011\000\022\000\016\000"

let yysindex = "\255\255\
\005\255\000\000\004\255\009\255\000\000\000\000\011\255\000\000\
\013\255\000\000\001\255\000\000\024\255\000\000\000\000\001\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\012\255\025\255\026\255\000\000\027\255\028\255\021\255\029\255\
\030\255\031\255\035\255\036\255\037\255\038\255\039\255\040\255\
\041\255\042\255\046\255\047\255\048\255\049\255\050\255\051\255\
\052\255\053\255\016\255\018\255\020\255\022\255\000\000\032\255\
\000\000\058\255\000\000\059\255\000\000\060\255\000\000\000\000\
\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yytablesize = 261
let yytable = "\001\000\
\028\000\017\000\018\000\019\000\020\000\021\000\003\000\007\000\
\004\000\008\000\009\000\012\000\013\000\014\000\029\000\030\000\
\055\000\056\000\057\000\058\000\059\000\060\000\061\000\062\000\
\023\000\035\000\031\000\032\000\033\000\034\000\000\000\000\000\
\063\000\036\000\037\000\038\000\039\000\040\000\041\000\042\000\
\000\000\000\000\000\000\043\000\044\000\045\000\046\000\047\000\
\048\000\049\000\050\000\000\000\000\000\000\000\051\000\052\000\
\053\000\054\000\064\000\065\000\066\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\024\000\025\000\026\000\027\000"

let yycheck = "\001\000\
\000\000\001\001\002\001\003\001\004\001\005\001\002\001\004\001\
\004\001\001\001\002\001\001\001\002\001\001\001\003\001\004\001\
\001\001\002\001\001\001\002\001\001\001\002\001\001\001\002\001\
\001\001\005\001\002\001\002\001\002\001\002\001\255\255\255\255\
\001\001\005\001\005\001\005\001\002\001\002\001\002\001\002\001\
\255\255\255\255\255\255\005\001\005\001\005\001\005\001\002\001\
\002\001\002\001\002\001\255\255\255\255\255\255\005\001\005\001\
\005\001\005\001\001\001\001\001\001\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\001\001\002\001\003\001\004\001"

let yynames_const = "\
  EOL\000\
  EOF\000\
  "

let yynames_block = "\
  SPACE\000\
  WORD\000\
  INTEGER\000\
  FLOAT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'integer) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'title) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'atoms_xyz) in
    Obj.repr(
# 36 "qcaml/particles/lib/xyz_parser.mly"
                            (
      {
        number_of_atoms = _1;
        file_title = _2;
        nuclei = _3;
      }
    )
# 192 "qcaml/particles/lib/xyz_parser.ml"
               : Xyz_ast.xyz_file))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 47 "qcaml/particles/lib/xyz_parser.mly"
                ( _1 )
# 199 "qcaml/particles/lib/xyz_parser.ml"
               : 'integer))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 48 "qcaml/particles/lib/xyz_parser.mly"
                      ( _1 )
# 207 "qcaml/particles/lib/xyz_parser.ml"
               : 'integer))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 49 "qcaml/particles/lib/xyz_parser.mly"
                      ( _2 )
# 215 "qcaml/particles/lib/xyz_parser.ml"
               : 'integer))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 50 "qcaml/particles/lib/xyz_parser.mly"
                            ( _2 )
# 224 "qcaml/particles/lib/xyz_parser.ml"
               : 'integer))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'title_list) in
    Obj.repr(
# 54 "qcaml/particles/lib/xyz_parser.mly"
                   ( _1 )
# 231 "qcaml/particles/lib/xyz_parser.ml"
               : 'title))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 58 "qcaml/particles/lib/xyz_parser.mly"
            ( _1 )
# 238 "qcaml/particles/lib/xyz_parser.ml"
               : 'text))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 59 "qcaml/particles/lib/xyz_parser.mly"
            ( _1 )
# 245 "qcaml/particles/lib/xyz_parser.ml"
               : 'text))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 60 "qcaml/particles/lib/xyz_parser.mly"
            ( (string_of_float _1))
# 252 "qcaml/particles/lib/xyz_parser.ml"
               : 'text))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 61 "qcaml/particles/lib/xyz_parser.mly"
            ( (string_of_int _1))
# 259 "qcaml/particles/lib/xyz_parser.ml"
               : 'text))
; (fun __caml_parser_env ->
    Obj.repr(
# 65 "qcaml/particles/lib/xyz_parser.mly"
    ( "" )
# 265 "qcaml/particles/lib/xyz_parser.ml"
               : 'title_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'title_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'text) in
    Obj.repr(
# 66 "qcaml/particles/lib/xyz_parser.mly"
                    ( (_1 ^ _2) )
# 273 "qcaml/particles/lib/xyz_parser.ml"
               : 'title_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'atoms_list) in
    Obj.repr(
# 70 "qcaml/particles/lib/xyz_parser.mly"
                   ( List.rev _1 )
# 280 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_xyz))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'atoms_list) in
    Obj.repr(
# 71 "qcaml/particles/lib/xyz_parser.mly"
                   ( List.rev _1 )
# 287 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_xyz))
; (fun __caml_parser_env ->
    Obj.repr(
# 75 "qcaml/particles/lib/xyz_parser.mly"
    ( [] )
# 293 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 8 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 5 : float) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 3 : float) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 1 : float) in
    Obj.repr(
# 76 "qcaml/particles/lib/xyz_parser.mly"
                                                                     ( output_of_string _4 _6 _8 _2 :: _1 )
# 307 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 9 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : float) in
    let _5 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : float) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : float) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 77 "qcaml/particles/lib/xyz_parser.mly"
                                                                     ( output_of_string _4 _6 _8 _2 :: _1 )
# 322 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 8 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 7 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 5 : float) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 3 : float) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 1 : float) in
    Obj.repr(
# 78 "qcaml/particles/lib/xyz_parser.mly"
                                                                     ( output_of_int    _4 _6 _8 _2 :: _1 )
# 336 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 9 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 8 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : float) in
    let _5 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : float) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : float) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 79 "qcaml/particles/lib/xyz_parser.mly"
                                                                     ( output_of_int    _4 _6 _8 _2 :: _1 )
# 351 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 9 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 5 : float) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : float) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : float) in
    Obj.repr(
# 80 "qcaml/particles/lib/xyz_parser.mly"
                                                                           ( output_of_string _5 _7 _9 _3 :: _1 )
# 366 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 10 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 6 : float) in
    let _6 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 4 : float) in
    let _8 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : float) in
    let _10 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 81 "qcaml/particles/lib/xyz_parser.mly"
                                                                           ( output_of_string _5 _7 _9 _3 :: _1 )
# 382 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 9 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 5 : float) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : float) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : float) in
    Obj.repr(
# 82 "qcaml/particles/lib/xyz_parser.mly"
                                                                           ( output_of_int    _5 _7 _9 _3 :: _1 )
# 397 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 10 : 'atoms_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 8 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 6 : float) in
    let _6 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 4 : float) in
    let _8 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : float) in
    let _10 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 83 "qcaml/particles/lib/xyz_parser.mly"
                                                                           ( output_of_int    _5 _7 _9 _3 :: _1 )
# 413 "qcaml/particles/lib/xyz_parser.ml"
               : 'atoms_list))
(* Entry input *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let input (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Xyz_ast.xyz_file)
