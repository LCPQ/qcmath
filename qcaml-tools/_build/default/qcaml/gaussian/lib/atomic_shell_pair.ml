(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Type][Type:2]] *)
open Common

type t =
{
  contracted_shell_pairs : Contracted_shell_pair.t list;
  atomic_shell_a         : Atomic_shell.t;
  atomic_shell_b         : Atomic_shell.t;
}


module Am  = Angular_momentum
module As  = Atomic_shell
module Co  = Coordinate
module Cs  = Contracted_shell
module Csp = Contracted_shell_pair
(* Type:2 ends here *)



(* | ~atomic_shell_a~         | Returns the first  ~Atomic_shell.t~ which was used to build the atomic shell pair.                                                 |
 * | ~atomic_shell_b~         | Returns the second ~Atomic_shell.t~ which was used to build the atomic shell pair.                                                 |
 * | ~contracted_shell_pairs~ | Returns an array of ~ContractedShellPair.t~, containing all the pairs of contracted functions used to build the atomic shell pair. |
 * | ~norm_scales~            | norm_coef.(i) / norm_coef.(0)                                                                                                      |
 * | ~ang_mom~                | Total angular Momentum                                                                                                             |
 * | ~monocentric~            | If true, the two atomic shells have the same center.                                                                               |
 * | ~a_minus_b~              | Returns $A-B$                                                                                                                      |
 * | ~a_minus_b_sq~           | Returns $\vert A-B \vert^2$                                                                                                        | *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Access][Access:2]] *)
let atomic_shell_a         x = x.atomic_shell_a
let atomic_shell_b         x = x.atomic_shell_b
let contracted_shell_pairs x = x.contracted_shell_pairs

let monocentric x =
  Csp.monocentric @@ List.hd x.contracted_shell_pairs

let a_minus_b x =
  Csp.a_minus_b @@ List.hd x.contracted_shell_pairs

let a_minus_b_sq x =
  Csp.a_minus_b_sq @@ List.hd x.contracted_shell_pairs

let ang_mom x =
  Csp.ang_mom @@ List.hd x.contracted_shell_pairs

let norm_scales x =
  Csp.norm_scales @@ List.hd x.contracted_shell_pairs
(* Access:2 ends here *)



(* Creates all possible atomic shell pairs from an array of atomic shells.
 * If an atomic shell pair is not significant, sets the value to ~None~. *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Creation][Creation:3]] *)
let make ?(cutoff=Constants.epsilon) atomic_shell_a atomic_shell_b =

  let l_a = Array.to_list (As.contracted_shells atomic_shell_a)
  and l_b = Array.to_list (As.contracted_shells atomic_shell_b)
  in

  let contracted_shell_pairs =
    List.concat_map (fun s_a -> 
      List.map (fun s_b ->
        if Cs.index s_b <= Cs.index s_a then 
          Csp.make ~cutoff s_a s_b
        else
          None
      ) l_b
    ) l_a
    |> Util.list_some
  in
  match contracted_shell_pairs with
  | [] -> None
  | _  -> Some { atomic_shell_a ; atomic_shell_b ; contracted_shell_pairs }



let of_atomic_shell_array ?(cutoff=Constants.epsilon) basis =
  Array.mapi (fun i shell_a ->
    Array.map (fun shell_b -> 
      make ~cutoff shell_a shell_b)
    (Array.sub basis 0 (i+1)) 
  ) basis
(* Creation:3 ends here *)

(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Printers][Printers:2]] *)
let pp ppf s =
  let open Format in
  fprintf ppf "@[%a@ %a@]"
    Atomic_shell.pp s.atomic_shell_a
    Atomic_shell.pp s.atomic_shell_b
(* Printers:2 ends here *)
