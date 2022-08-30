open Common

type t = 
{
  coefs_and_shell_pair_couples : (float * Primitive_shell_pair_couple.t) list ;
  shell_pair_p: Contracted_shell_pair.t ;
  shell_pair_q: Contracted_shell_pair.t ;
  shell_a     : Contracted_shell.t ;
  shell_b     : Contracted_shell.t ;
  shell_c     : Contracted_shell.t ;
  shell_d     : Contracted_shell.t ;
  ang_mom     : Angular_momentum.t ;
}

module Am   = Angular_momentum
module Co   = Coordinate
module Cs   = Contracted_shell
module Csp  = Contracted_shell_pair
module Pspc = Primitive_shell_pair_couple

let make ?(cutoff=Constants.epsilon) shell_pair_p shell_pair_q = 
  let ang_mom =
    Am.(Csp.ang_mom shell_pair_p + Csp.ang_mom shell_pair_q)
  in
  let shell_a = Csp.shell_a shell_pair_p
  and shell_b = Csp.shell_b shell_pair_p
  and shell_c = Csp.shell_a shell_pair_q
  and shell_d = Csp.shell_b shell_pair_q
  in
  let cutoff = 1.e-3 *. cutoff in
  let coefs_and_shell_pair_couples =
    List.concat_map (fun (c_ab, sp_ab) -> 
      List.map (fun (c_cd, sp_cd) -> 
        let coef_prod = c_ab *. c_cd in
        if abs_float coef_prod < cutoff then None
        else Some (coef_prod, Pspc.make sp_ab sp_cd)
      ) (Csp.coefs_and_shell_pairs shell_pair_q)
    ) (Csp.coefs_and_shell_pairs shell_pair_p)
    |> Util.list_some
  in
  match coefs_and_shell_pair_couples with
  | [] -> None 
  | _  -> Some {  shell_pair_p ; shell_pair_q ; ang_mom ;
                  shell_a ; shell_b ; shell_c ; shell_d ;
                  coefs_and_shell_pair_couples ;
                }

let coefs_and_shell_pair_couples t = t.coefs_and_shell_pair_couples

let monocentric t =
  Csp.monocentric t.shell_pair_p && Csp.monocentric t.shell_pair_q &&
  Cs.center (Csp.shell_a t.shell_pair_p) = Cs.center (Csp.shell_a t.shell_pair_q)


let ang_mom t = t.ang_mom

let shell_pair_p t = t.shell_pair_p
let shell_pair_q t = t.shell_pair_q

let shell_a t = t.shell_a
let shell_b t = t.shell_b
let shell_c t = t.shell_c
let shell_d t = t.shell_d


let zkey_array t =
  match t.coefs_and_shell_pair_couples with
  | (_,f)::_ -> Pspc.zkey_array f
  |  _ -> invalid_arg "ContractedShellPairCouple.zkey_array"

let norm_scales t = 
  match t.coefs_and_shell_pair_couples with
  | (_,f)::_ -> Pspc.norm_scales f
  |  _ -> invalid_arg "ContractedShellPairCouple.norm_scales"

