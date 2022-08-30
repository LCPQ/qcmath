(* [[file:~/QCaml/perturbation/mp2.org::*Type][Type:2]] *)
type t = {
  energy      : float ;
  mo_basis    : Mo.Basis.t ;
  frozen_core : Mo.Frozen_core.t ;
}
(* Type:2 ends here *)



(*    | ~make~ | Creates an MP2 data structure |
 * 
 *    #+begin_example
 * let mp2 =
 *   Perturbation.Mp2.make ~frozen_core:(Mo.Frozen_core.(make Small nuclei)) mo_basis
 *   ;;
 * val mp2 : Perturbation.Mp2.t = E(MP2)=-0.185523
 *    #+end_example *)


(* [[file:~/QCaml/perturbation/mp2.org::*Creation][Creation:2]] *)
open Linear_algebra

let make_rmp2 mo_basis mo_class =

  let epsilon = Mo.Basis.mo_energies mo_basis in
  let eri     = Mo.Basis.ee_ints     mo_basis in

  let inactives =
    List.filter (fun i ->
      match i with Mo.Class.Inactive _ -> true | _ -> false) mo_class
  and virtuals =
    List.filter (fun i ->
      match i with Mo.Class.Virtual _ -> true | _ -> false) mo_class
  in

  List.fold_left (fun accu b ->
    match b with Mo.Class.Virtual b ->
      let eps = -. (epsilon%.(b)) in
      accu +. 
      List.fold_left (fun accu a ->
        match a with Mo.Class.Virtual a ->
          let eps = eps -. (epsilon%.(a)) in
          accu +. 
          List.fold_left (fun accu j ->
            match j with Mo.Class.Inactive j ->
              let eps = eps +. epsilon%.(j) in
              accu +. 
              List.fold_left (fun accu i ->
                match i with Mo.Class.Inactive i ->
                  let eps = eps +. epsilon%.(i) in
                  let ijab = Four_idx_storage.get_phys eri i j a b
                  and abji = Four_idx_storage.get_phys eri a b j i in
                  let abij =  ijab in
                  accu +. ijab *. ( abij +. abij -. abji) /. eps 
                           | _ -> accu
              ) 0. inactives
                       | _ -> accu
          ) 0. inactives
                   | _ -> accu
      ) 0. virtuals
               | _ -> accu
  ) 0. virtuals


let make ~frozen_core mo_basis =

  let mo_class =
    Mo.Class.cas_sd mo_basis ~frozen_core 0 0
    |> Mo.Class.to_list
  in

  let energy = 
    match Mo.Basis.mo_type mo_basis with
    | RHF  -> make_rmp2 mo_basis mo_class
    | ROHF -> Common.Util.not_implemented "ROHF MP2"
    | UHF  -> Common.Util.not_implemented "UHF MP2"
    | _    -> invalid_arg "MP2 needs RHF or ROHF MOs"
  in
  { energy ; mo_basis ; frozen_core }
(* Creation:2 ends here *)



(* | ~energy~      | Returns the MP2 energy                                        |
 * | ~mo_basis~    | Returns the MO basis on which the MP2 energy was computed     |
 * | ~frozen_core~ | Returns the frozen_core scheme used to compute the MP2 energy |
 * 
 * #+begin_example
 * 
 * #+end_example *)


(* [[file:~/QCaml/perturbation/mp2.org::*Access][Access:2]] *)
let energy      t = t.energy
let mo_basis    t = t.mo_basis
let frozen_core t = t.frozen_core
(* Access:2 ends here *)

(* [[file:~/QCaml/perturbation/mp2.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[E(MP2)=%f@]" t.energy
(* Printers:2 ends here *)
