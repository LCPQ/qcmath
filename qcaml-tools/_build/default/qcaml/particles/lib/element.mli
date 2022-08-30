(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/particles/element.org::types][types]] *)
type t =
  |X
  |H                                                 |He
  |Li|Be                              |B |C |N |O |F |Ne
  |Na|Mg                              |Al|Si|P |S |Cl|Ar
  |K |Ca|Sc|Ti|V |Cr|Mn|Fe|Co|Ni|Cu|Zn|Ga|Ge|As|Se|Br|Kr
  |Rb|Sr|Y |Zr|Nb|Mo|Tc|Ru|Rh|Pd|Ag|Cd|In|Sn|Sb|Te|I |Xe
                          |Pt          

exception ElementError of string

open Common
(* types ends here *)

(* Conversion *)


(* [[file:~/QCaml/particles/element.org::*Conversion][Conversion:1]] *)
val of_string      : string -> t
val to_string      : t -> string
val to_long_string : t -> string

val to_int : t -> int 
val of_int : int -> t

val to_charge : t -> Charge.t
val of_charge : Charge.t -> t
(* Conversion:1 ends here *)

(* Database information *)


(* [[file:~/QCaml/particles/element.org::*Database information][Database information:1]] *)
val covalent_radius : t -> Non_negative_float.t
val vdw_radius      : t -> Non_negative_float.t
val mass            : t -> Mass.t
val small_core      : t -> int
val large_core      : t -> int
(* Database information:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/particles/element.org::*Printers][Printers:1]] *)
val pp      : Format.formatter -> t -> unit
val pp_long : Format.formatter -> t -> unit
(* Printers:1 ends here *)
