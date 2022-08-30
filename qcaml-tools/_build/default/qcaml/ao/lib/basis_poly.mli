(* Polymorphic types
 * 
 *    <<<~Basis.t~>>>
 *    #+NAME: types *)

(* [[file:~/QCaml/ao/basis.org::types][types]] *)
type t =
  | Unknown
  | Gaussian of Basis_gaussian.t
(* types ends here *)
