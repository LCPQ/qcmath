(* [[file:~/QCaml/particles/electrons.org::*Type][Type:2]] *)
type t = {
  n_alfa : int ;
  n_beta : int ;
}
(* Type:2 ends here *)



(* | ~make~     | ~make n_alfa n_beta~                                                                                                                  |
 * | ~of_atoms~ | Creates the data relative to electrons for a molecular system described by ~Nuclei.t~ for a given total charge and spin multiplicity. | *)


(* [[file:~/QCaml/particles/electrons.org::*Creation][Creation:2]] *)
open Common

let make n_alfa n_beta = 
  { n_alfa ; n_beta }


let of_atoms ?multiplicity:(multiplicity=1) ?charge:(charge=0) nuclei =
  let positive_charges =
    Array.fold_left (fun accu (e, _) -> accu + Charge.to_int (Element.to_charge e) )
      0 nuclei
  in
  let negative_charges = charge - positive_charges in
  let n_elec = - negative_charges in
  let n_beta = ((n_elec - multiplicity)+1)/2 in
  let n_alfa = n_elec - n_beta in
  let result = { n_alfa ; n_beta } in
  if multiplicity <> (n_alfa - n_beta)+1 then
    invalid_arg (__FILE__^": make");
  result
(* Creation:2 ends here *)



(* | ~charge~       | Sum of the charges of the electrons |
 * | ~n_elec~       | Number of electrons                 |
 * | ~n_alfa~       | Number of alpha electrons           |
 * | ~n_beta~       | Number of beta  electrons           |
 * | ~multiplicity~ | Spin multiplicity: $2S+1$           | *)


(* [[file:~/QCaml/particles/electrons.org::*Access][Access:2]] *)
let charge e =
  - (e.n_alfa + e.n_beta)
  |> Charge.of_int

let n_alfa t = t.n_alfa

let n_beta t = t.n_beta

let n_elec t = t.n_alfa + t.n_beta

let multiplicity t = t.n_alfa - t.n_beta + 1
(* Access:2 ends here *)

(* [[file:~/QCaml/particles/electrons.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[n_alfa=%d, n_beta=%d@]" t.n_alfa t.n_beta
(* Printers:2 ends here *)
