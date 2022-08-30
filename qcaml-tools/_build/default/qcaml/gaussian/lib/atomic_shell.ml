(* [[file:~/QCaml/gaussian/atomic_shell.org::*Type][Type:2]] *)
open Common

type t = {
    expo      : float array array;
    coef      : float array array;
    norm_coef : float array array;
    norm_coef_scale : float array;
    contr     : Contracted_shell.t array;
    index     : int;
    center    : Coordinate.t;
    ang_mom   : Angular_momentum.t;
  }

module Am = Angular_momentum
module Co = Coordinate
module Cs = Contracted_shell
(* Type:2 ends here *)



(* | ~ang_mom~            | Total angular momentum : $l = n_x + n_y + n_z$.                                                                                                             |
 * | ~center~             | Coordinate of the center $\mathbf{A} = (X_A,Y_A,Z_A)$.                                                                                                      |
 * | ~coefficients~       | Array of contraction coefficients $d_{ij}$. The first index is the index of the contracted function, and the second index is the index of the primitive.    |
 * | ~contracted_shells:~ | Array of contracted gaussians                                                                                                                               |
 * | ~exponents~          | Array of exponents $\alpha_{ij}$. The first index is the index of the contracted function, and the second index is the index of the primitive.              |
 * | ~index~              | Index in the basis set, represented as an array of contracted shells.                                                                                       |
 * | ~normalizations~     | Normalization coefficients $\mathcal{N}_{ij}$. The first index is the index of the contracted function, and the second index is the index of the primitive. |
 * | ~norm_scales~        | Scaling factors $f(n_x,n_y,n_z)$, given in the same order as ~Angular_momentum.zkey_array ang_mom~.                                                         |
 * | ~size~               | Number of contracted functions, $n$ in the definition.                                                                                                      |
 * | ~size_of_shell~      | Number of contracted functions in the shell: length of ~norm_coef_scale~.                                                                                   |
 * 
 * #+begin_example
 * 
 * #+end_example *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Access][Access:2]] *)
let ang_mom           t = t.ang_mom
let center            t = t.center
let coefficients      t = t.coef
let contracted_shells t = t.contr
let exponents         t = t.expo
let index             t = t.index
let normalizations    t = t.norm_coef
let norm_scales       t = t.norm_coef_scale
let size_of_shell     t = Array.length t.norm_coef_scale
let size              t = Array.length t.contr
(* Access:2 ends here *)



(* | ~make~       | Creates a contracted shell from a list of coefficients and primitives. |
 * | ~with_index~ | Returns a copy of the contracted shell with a modified index.          | *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Creation][Creation:2]] *)
let make ?(index=0) contr = 
  assert (Array.length contr > 0);

  let coef = Array.map Cs.coefficients contr
  and expo = Array.map Cs.exponents contr
  in

  let center = Cs.center contr.(0) in
  let rec unique_center = function
    | 0 -> true
    | i -> if Cs.center contr.(i) = center then (unique_center [@tailcall]) (i-1) else false
  in
  if not (unique_center (Array.length contr - 1)) then
    invalid_arg "ContractedAtomicShell.make Coordinate.t differ";
  
  let ang_mom = Cs.ang_mom contr.(0) in
  let rec unique_angmom = function
    | 0 -> true
    | i -> if Cs.ang_mom contr.(i) = ang_mom then (unique_angmom [@tailcall]) (i-1) else false
  in
  if not (unique_angmom (Array.length contr - 1)) then
    invalid_arg "Contracted_shell.make: Angular_momentum.t differ";
  
  let norm_coef =
    Array.map Cs.normalizations contr 
  in
  let norm_coef_scale = Cs.norm_scales contr.(0)
  in
  { index ; expo ; coef ; center ; ang_mom ; norm_coef ;
    norm_coef_scale ; contr  }


let with_index a i =
  { a with index = i }
(* Creation:2 ends here *)

(* [[file:~/QCaml/gaussian/atomic_shell.org::*Printers][Printers:2]] *)
let pp ppf s =
  let open Format in
  fprintf ppf "@[%3d-%-3d@]" (s.index+1) (s.index+ (size_of_shell s)*(size s));
  fprintf ppf "@[%a@ %a@] @[" Am.pp_string s.ang_mom Co.pp s.center;
  Array.iter2 (fun e_arr c_arr -> fprintf ppf "@[<v>";
                                  Array.iter2 (fun e c -> fprintf ppf "@[%16.8e  %16.8e@]@;" e c)
                                    e_arr c_arr;
                                  fprintf ppf "@;@]") s.expo s.coef;
  fprintf ppf "@]"
(* Printers:2 ends here *)
