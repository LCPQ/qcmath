open Common
    
type t = 
{
  zkey_array  : Zkey.t array lazy_t;
  shell_pair_p: Primitive_shell_pair.t ;
  shell_pair_q: Primitive_shell_pair.t ;
  shell_a     : Primitive_shell.t ;
  shell_b     : Primitive_shell.t ;
  shell_c     : Primitive_shell.t ;
  shell_d     : Primitive_shell.t ;
  ang_mom     : Angular_momentum.t ;
}

module Am  = Angular_momentum
module Co  = Coordinate
module Ps  = Primitive_shell
module Psp = Primitive_shell_pair

let make shell_pair_p shell_pair_q = 
  let ang_mom =
    Am.(Psp.ang_mom shell_pair_p + Psp.ang_mom shell_pair_q)
  in
  let shell_a = Psp.shell_a shell_pair_p
  and shell_b = Psp.shell_b shell_pair_p
  and shell_c = Psp.shell_a shell_pair_q
  and shell_d = Psp.shell_b shell_pair_q
  in
  let zkey_array = lazy (
    Am.zkey_array (Am.Quartet
      Ps.(ang_mom shell_a, ang_mom shell_b,
          ang_mom shell_c, ang_mom shell_d)
    )
  )
  in
  { shell_pair_p ; shell_pair_q ; ang_mom ;
    shell_a ; shell_b ; shell_c ; shell_d ;
    zkey_array ;
  }



let monocentric t =
  Psp.monocentric t.shell_pair_p && Psp.monocentric t.shell_pair_q &&
  Psp.center t.shell_pair_p = Psp.center t.shell_pair_q


let ang_mom t = t.ang_mom

let shell_pair_p t = t.shell_pair_p
let shell_pair_q t = t.shell_pair_q

let shell_a t = t.shell_a
let shell_b t = t.shell_b
let shell_c t = t.shell_c
let shell_d t = t.shell_d

let p_minus_q t = 
  let p = Psp.center t.shell_pair_p
  and q = Psp.center t.shell_pair_q
  in Co.(p |- q)

let zkey_array t = Lazy.force t.zkey_array

let norm_scales t = 
  let norm_coef_scale_p_list = Array.to_list (Psp.norm_scales t.shell_pair_p) in
  let norm_coef_scale_q = Psp.norm_scales t.shell_pair_q in
  List.map (fun v1 -> Array.map (fun v2 -> v1 *. v2) norm_coef_scale_q)
    norm_coef_scale_p_list
  |> Array.concat



