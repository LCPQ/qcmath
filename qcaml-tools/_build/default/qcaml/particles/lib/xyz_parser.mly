%{
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

%}

%token EOL
%token <string> SPACE
%token <string> WORD
%token <int> INTEGER
%token <float> FLOAT
%token EOF

%start input
%type <Xyz_ast.xyz_file> input

%% /* Grammar rules and actions follow */

input:
  | integer title atoms_xyz {
      {
        number_of_atoms = $1;
        file_title = $2;
        nuclei = $3;
      }
    }
;


integer:
  | INTEGER EOL { $1 }
  | INTEGER SPACE EOL { $1 }
  | SPACE INTEGER EOL { $2 }
  | SPACE INTEGER SPACE EOL { $2 }
;

title:
  | title_list EOL { $1 }
;

text:
  | WORD    { $1 }
  | SPACE   { $1 }
  | FLOAT   { (string_of_float $1)}
  | INTEGER { (string_of_int $1)}
;

title_list:
  | { "" }
  | title_list text { ($1 ^ $2) }
;

atoms_xyz:
  | atoms_list EOL { List.rev $1 }
  | atoms_list EOF { List.rev $1 }
;

atoms_list:
  | { [] }
  | atoms_list WORD    SPACE FLOAT SPACE FLOAT SPACE FLOAT       EOL { output_of_string $4 $6 $8 $2 :: $1 }
  | atoms_list WORD    SPACE FLOAT SPACE FLOAT SPACE FLOAT SPACE EOL { output_of_string $4 $6 $8 $2 :: $1 }
  | atoms_list INTEGER SPACE FLOAT SPACE FLOAT SPACE FLOAT       EOL { output_of_int    $4 $6 $8 $2 :: $1 }
  | atoms_list INTEGER SPACE FLOAT SPACE FLOAT SPACE FLOAT SPACE EOL { output_of_int    $4 $6 $8 $2 :: $1 }
  | atoms_list SPACE WORD    SPACE FLOAT SPACE FLOAT SPACE FLOAT       EOL { output_of_string $5 $7 $9 $3 :: $1 }
  | atoms_list SPACE WORD    SPACE FLOAT SPACE FLOAT SPACE FLOAT SPACE EOL { output_of_string $5 $7 $9 $3 :: $1 }
  | atoms_list SPACE INTEGER SPACE FLOAT SPACE FLOAT SPACE FLOAT       EOL { output_of_int    $5 $7 $9 $3 :: $1 }
  | atoms_list SPACE INTEGER SPACE FLOAT SPACE FLOAT SPACE FLOAT SPACE EOL { output_of_int    $5 $7 $9 $3 :: $1 }
;
