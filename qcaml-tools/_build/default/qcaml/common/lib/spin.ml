

(* Note :
 * ~Alfa~ if written with an 'f' instead of 'ph' because it has the same number of
 * letters as ~Beta~, so the alignment of the code is nicer. *)


(* [[file:~/QCaml/common/spin.org::*Type][Type:2]] *)
type t =  (* m_s *)
  | Alfa (* {% $m_s = +1/2$ %} *)
  | Beta (* {% $m_s = -1/2$ %} *)
(* Type:2 ends here *)



(* Returns the opposite spin *)


(* [[file:~/QCaml/common/spin.org::*Functions][Functions:2]] *)
let other = function
  | Alfa -> Beta
  | Beta -> Alfa

let to_string = function
  | Alfa -> "Alpha"
  | Beta -> "Beta "
(* Functions:2 ends here *)

(* [[file:~/QCaml/common/spin.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[%s@]" (to_string t)
(* Printers:2 ends here *)
