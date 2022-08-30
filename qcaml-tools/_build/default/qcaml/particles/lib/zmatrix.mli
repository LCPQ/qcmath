(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/particles/zmatrix.org::types][types]] *)
type t
(* types ends here *)

(* Conversion *)


(* [[file:~/QCaml/particles/zmatrix.org::*Conversion][Conversion:1]] *)
val of_string      : string -> t
val to_xyz         : t -> (Element.t * float * float * float) array
val to_xyz_string  : t -> string
(* Conversion:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/particles/zmatrix.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
