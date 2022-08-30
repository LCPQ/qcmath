(** General basis set read from a file.

Basis set files are stored in GAMESS format, for example:
{[
HYDROGEN
S   3
  1     13.0100000              0.0196850
  2      1.9620000              0.1379770
  3      0.4446000              0.4781480
S   1
  1      0.1220000              1.0000000
P   1
  1      0.7270000              1.0000000

HELIUM
S   3
  1     38.3600000              0.0238090
  2      5.7700000              0.1548910
  3      1.2400000              0.4699870
S   1
  1      0.2976000              1.0000000
P   1
  1      1.2750000              1.0000000
]}

When building the atomic basis set of a molecular system, the basis functions
are created by picking the data from the general basis set. This data structure
simplifies the creation of the atomic basis set.
*)

open Common
open Particles

type primitive = private
  {
    exponent   : float ;
    coefficient: float ;
  }

type general_contracted_shell = Angular_momentum.t * (primitive array)

type element_basis = Element.t * (general_contracted_shell array)

type t = element_basis list


exception No_shell
exception Malformed_shell of string


val read : string -> t
(** Reads a basis-set file and return an association list where
    the key is an {!Element.t} and the value is the parsed basis set.
*)


val combine : t list -> t
(** Combines the basis functions of each element among different basis sets.
    Used to complement a basis with an auxiliary basis set.
*)


val read_many : string list -> t
(** Reads multiple basis set files and return an association list where
    the key is an {!Element.t} and the value is the parsed basis set.
    This function is usually used to add an auxiliary basis set.
*)



val read_element : string Stream.t -> element_basis option
(** Reads an element from the input [string Stream]. The [string Stream] is a
stream of lines, like a text file split on the end-of-line character.
For example,
{[
HYDROGEN
S   3
  1     13.0100000              0.0196850
  2      1.9620000              0.1379770
  3      0.4446000              0.4781480
S   1
  1      0.1220000              1.0000000
P   1
  1      0.7270000              1.0000000

}]
returns
{[
Some
 (Element.H,
  [(Angular_momentum.S,
    [{exponent = 13.01; coefficient = 0.019685};
     {exponent = 1.962; coefficient = 0.137977};
     {exponent = 0.4446; coefficient = 0.478148}]);
   (Angular_momentum.S, [{exponent = 0.122; coefficient = 1.}]);
   (Angular_momentum.P, [{exponent = 0.727; coefficient = 1.}])])
]}

@raise Malformed_shell if the input is not well formed.
*)
  

val read_shell : string Stream.t -> general_contracted_shell option
(** Reads a shell from the input [string Stream]. The [string Stream] is a 
stream of lines, like a text file split on the end-of-line character.
For example,
{[
S   3
  1     13.0100000              0.0196850
  2      1.9620000              0.1379770
  3      0.4446000              0.4781480
]}
returns
{[
Some
 (Angular_momentum.S,
  [{exponent = 13.01 ; coefficient = 0.019685};
   {exponent = 1.962 ; coefficient = 0.137977};
   {exponent = 0.4446; coefficient = 0.478148}])
]}

@raise Malformed_shell if the input is not well formed.
*)


val to_string : string * (general_contracted_shell array) -> string
(** Pretty-prints the basis set of an {Element.t}. *)

val of_string : string -> t
(** Reads a GAMESS-formatted string. *)


(** Pretty printers *)

val pp_primitive : Format.formatter -> primitive -> unit
val pp_gcs       : Format.formatter -> general_contracted_shell -> unit
val pp_element_basis : Format.formatter -> element_basis -> unit

val pp : Format.formatter -> t -> unit
