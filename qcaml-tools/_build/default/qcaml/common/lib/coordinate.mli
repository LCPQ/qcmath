(* Type
 * 
 *    <<<~Coordinate.t~>>>
 *    #+NAME: types *)

(* [[file:~/QCaml/common/coordinate.org::types][types]] *)
type bohr 
type angstrom 

type xyz = {
  x : float ;
  y : float ;
  z : float ;
}

type 'a point = xyz

type t = bohr point

type axis = X | Y | Z
(* types ends here *)

(* Creation  *)


(* [[file:~/QCaml/common/coordinate.org::*Creation][Creation:1]] *)
val make          : 'a point -> t
val make_angstrom : 'a point -> angstrom point
val zero          : bohr point
(* Creation:1 ends here *)

(* Conversion *)


(* [[file:~/QCaml/common/coordinate.org::*Conversion][Conversion:1]] *)
val bohr_to_angstrom : bohr point -> angstrom point
val angstrom_to_bohr : angstrom point -> bohr point
(* Conversion:1 ends here *)

(* Vector operations *)


(* [[file:~/QCaml/common/coordinate.org::*Vector%20operations][Vector operations:1]] *)
val neg    : t -> t
val get    : axis -> bohr point -> float
val dot    : t -> t -> float
val norm   : t -> float
val ( |. ) : float -> t -> t
val ( |+ ) : t -> t -> t
val ( |- ) : t -> t -> t
(* Vector operations:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/coordinate.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
val pp_bohr: Format.formatter -> t -> unit
val pp_angstrom : Format.formatter -> t -> unit
(* Printers:1 ends here *)
