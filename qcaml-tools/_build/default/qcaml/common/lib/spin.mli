(* Type
 * 
 *    <<<~Spin.t~>>> *)

(* [[file:~/QCaml/common/spin.org::*Type][Type:1]] *)
type t = Alfa | Beta
(* Type:1 ends here *)

(* Functions *)


(* [[file:~/QCaml/common/spin.org::*Functions][Functions:1]] *)
val other : t -> t
(* Functions:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/spin.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
