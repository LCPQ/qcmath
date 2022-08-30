(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Type][Type:2]] *)
open Common

type t = 
{
  contracted_shell_pair_couples : Contracted_shell_pair_couple.t list ;
  atomic_shell_pair_p: Atomic_shell_pair.t ;
  atomic_shell_pair_q: Atomic_shell_pair.t ;
  atomic_shell_a     : Atomic_shell.t ;
  atomic_shell_b     : Atomic_shell.t ;
  atomic_shell_c     : Atomic_shell.t ;
  atomic_shell_d     : Atomic_shell.t ;
  ang_mom            : Angular_momentum.t ;
}

module Am   = Angular_momentum
module Co   = Coordinate
module As   = Atomic_shell
module Asp  = Atomic_shell_pair
module Cspc = Contracted_shell_pair_couple
(* Type:2 ends here *)



(* | ~ang_mom~                       | Total angular momentum of the shell pair couple: sum of the angular momenta of all the shells.            |
 * | ~atomic_shell_a~                | Returns the first atomic shell of the first shell pair.                                                   |
 * | ~atomic_shell_b~                | Returns the second atomic shell of the first shell pair.                                                  |
 * | ~atomic_shell_c~                | Returns the first atomic shell of the second shell pair.                                                  |
 * | ~atomic_shell_d~                | Returns the second atomic shell of the second shell pair.                                                 |
 * | ~atomic_shell_pair_p~           | Returns the first atomic shell pair that was used to build the shell pair.                                |
 * | ~atomic_shell_pair_q~           | Returns the second atomic shell pair that was used to build the shell pair.                               |
 * | ~contracted_shell_pair_couples~ | Returns the list of significant contracted shell pair couples.                                            |
 * | ~monocentric~                   | True if all four atomic shells have the same center.                                                      |
 * | ~norm_scales~                   | Scaling factors of normalization coefficients inside the shell. The ordering is the same as ~zkey_array~. |
 * | ~zkey_array~                    | Returns the array of ~Zkey.t~ relative to the four shells of the shell pair couple.                       | *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Access][Access:2]] *)
let contracted_shell_pair_couples t = t.contracted_shell_pair_couples

let monocentric t =
  Asp.monocentric t.atomic_shell_pair_p && Asp.monocentric t.atomic_shell_pair_q &&
    As.center (Asp.atomic_shell_a t.atomic_shell_pair_p) = As.center (Asp.atomic_shell_a t.atomic_shell_pair_q)


let ang_mom t = t.ang_mom

let atomic_shell_pair_p t = t.atomic_shell_pair_p
let atomic_shell_pair_q t = t.atomic_shell_pair_q

let atomic_shell_a t = t.atomic_shell_a
let atomic_shell_b t = t.atomic_shell_b
let atomic_shell_c t = t.atomic_shell_c
let atomic_shell_d t = t.atomic_shell_d


let zkey_array t =
  match t.contracted_shell_pair_couples with
  | f::_ -> Cspc.zkey_array f
  |  _ -> invalid_arg "AtomicShellPairCouple.zkey_array"

let norm_scales t = 
  match t.contracted_shell_pair_couples with
  | f::_ -> Cspc.norm_scales f
  |  _ -> invalid_arg "AtomicShellPairCouple.norm_scales"
(* Access:2 ends here *)


(* Default cutoff is $\epsilon$.
 * 
 * | ~make~ | Creates an atomic shell pair couple using two atomic shell pairs. |
 * 
 * #+begin_example
 * 
 * #+end_example *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Creation][Creation:2]] *)
let make ?(cutoff=Constants.epsilon) atomic_shell_pair_p atomic_shell_pair_q = 
  let ang_mom =
    Am.(Asp.ang_mom atomic_shell_pair_p + Asp.ang_mom atomic_shell_pair_q)
  in
  let atomic_shell_a = Asp.atomic_shell_a atomic_shell_pair_p
  and atomic_shell_b = Asp.atomic_shell_b atomic_shell_pair_p
  and atomic_shell_c = Asp.atomic_shell_a atomic_shell_pair_q
  and atomic_shell_d = Asp.atomic_shell_b atomic_shell_pair_q
  in
  let contracted_shell_pair_couples =
    List.concat_map (fun ap_ab -> 
      List.map (fun ap_cd -> 
        Cspc.make ~cutoff ap_ab ap_cd
      ) (Asp.contracted_shell_pairs atomic_shell_pair_q)
    ) (Asp.contracted_shell_pairs atomic_shell_pair_p)
    |> Util.list_some
  in
  match contracted_shell_pair_couples with
  | [] -> None 
  | _  -> Some  { atomic_shell_pair_p ; atomic_shell_pair_q ; ang_mom ;
                  atomic_shell_a ; atomic_shell_b ; atomic_shell_c ; atomic_shell_d ;
                  contracted_shell_pair_couples ;
                }
(* Creation:2 ends here *)

(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "[(%d,%d),(%d,%d)]"
    (Atomic_shell.index t.atomic_shell_a)
    (Atomic_shell.index t.atomic_shell_b)
    (Atomic_shell.index t.atomic_shell_c)
    (Atomic_shell.index t.atomic_shell_d)
(* Printers:2 ends here *)
