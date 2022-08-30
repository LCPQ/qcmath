open Common
open Util
open Constants

type t = {
  norm_scales   : float array lazy_t;
  exponent      : float;
  normalization : float;
  center    : Coordinate.t;
  ang_mom   : Angular_momentum.t;
}

module Am = Angular_momentum


let compute_norm_coef alpha ang_mom =
  let atot =
    Am.to_int ang_mom
  in
  let factor int_array = 
       let dfa = Array.map (fun j ->
           ( float_of_int (1 lsl j) *. fact j) /. fact (j+j) 
         ) int_array
       in
       sqrt (dfa.(0) *.dfa.(1) *. dfa.(2))
  in
  let expo = 
    if atot mod 2 = 0 then
        let alpha_2 = alpha +. alpha in
        (alpha_2 *. pi_inv)**(0.75) *. (pow (alpha_2 +. alpha_2) (atot/2))
    else
        let alpha_2 = alpha +. alpha in
        (alpha_2 *. pi_inv)**(0.75) *. sqrt (pow (alpha_2 +. alpha_2) atot)
  in
  let f a =
    expo *. (factor a)
  in f


let make ang_mom center exponent =
  let norm_coef_func =
    compute_norm_coef exponent ang_mom
  in
  let norm =
    1. /. norm_coef_func [| Am.to_int ang_mom ; 0 ; 0 |] 
  in
  let powers =
    Am.zkey_array (Am.Singlet ang_mom) 
  in
  let norm_scales = lazy (
    Array.map (fun a ->
      (norm_coef_func (Zkey.to_int_array a)) *. norm
    ) powers )
  in
  let normalization = 1. /. norm in
  { exponent ; normalization ; norm_scales ; center ; ang_mom }


let to_string s =
  let coord = s.center in
  let open Coordinate in
  Printf.sprintf "%1s %8.3f %8.3f %8.3f  %16.8e" (Am.to_string s.ang_mom)
      (get X coord) (get Y coord) (get Z coord) s.exponent


(** Normalization coefficient of contracted function i, which depends on the
    exponent and the angular momentum. Two conventions can be chosen : a single
    normalization factor for all functions of the class, or a coefficient which
    depends on the powers of x,y and z.
    Returns, for each contracted function, an array of functions taking as
    argument the [|x;y;z|] powers.
*)

let exponent x = x.exponent

let center x = x.center

let ang_mom x = x.ang_mom

let norm x = 1. /. x.normalization

let normalization x = x.normalization

let norm_scales x = Lazy.force x.norm_scales

let size_of_shell x = Array.length (norm_scales x)

let zkey_array x = Am.(zkey_array (Singlet (x.ang_mom)))

