(* Type
 *    <<<~Nuclei.t~>>>
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/particles/nuclei.org::types][types]] *)
open Common

type t = (Element.t * Coordinate.t) array
(* types ends here *)

(* Conversion *)


(* [[file:~/QCaml/particles/nuclei.org::*Conversion][Conversion:1]] *)
val of_xyz_string : string -> t
val to_xyz_string  : t -> string
val of_xyz_file   : string -> t

val of_zmt_string : string -> t
val of_zmt_file   : string -> t

val to_string      : t -> string

val of_filename : string -> t
(* Conversion:1 ends here *)

(* TODO Query *)


(* [[file:~/QCaml/particles/nuclei.org::*Query][Query:1]] *)
val formula    : t -> string
val repulsion  : t -> float
val charge     : t -> Charge.t
val small_core : t -> int
val large_core : t -> int
(* Query:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/particles/nuclei.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
