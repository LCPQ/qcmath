open Common

type t = {
  expo      : float array;
  coef      : float array;
  norm_coef : float array;
  norm_coef_scale : float array;
  prim      : Primitive_shell.t array;
  center    : Coordinate.t;
  ang_mom   : Angular_momentum.t;
  index     : int;
}

module Am = Angular_momentum
module Co = Coordinate
module Ps = Primitive_shell


let make ?(index=0) lc = 
  assert (Array.length lc > 0);

  let coef = Array.map fst lc
  and prim = Array.map snd lc
  in

  let center = Ps.center prim.(0) in
  let rec unique_center = function
  | 0 -> true
  | i -> if Ps.center prim.(i) = center then (unique_center [@tailcall]) (i-1) else false
  in
  if not (unique_center (Array.length prim - 1)) then
    invalid_arg "ContractedShell.make Coordinate.t differ";
    
  let ang_mom = Ps.ang_mom prim.(0) in
  let rec unique_angmom = function
  | 0 -> true
  | i -> if Ps.ang_mom prim.(i) = ang_mom then (unique_angmom [@tailcall]) (i-1) else false
  in
  if not (unique_angmom (Array.length prim - 1)) then
    invalid_arg "ContractedShell.make: AngularMomentum.t differ";
    
  let expo = Array.map Ps.exponent prim in

  let norm_coef =
    Array.map Ps.normalization prim
  in
  let norm_coef_scale = Ps.norm_scales prim.(0)
  in
  { index ; expo ; coef ; center ; ang_mom ; norm_coef ;
    norm_coef_scale ; prim }


let with_index a i =
  { a with index = i }


let exponents x = x.expo

let coefficients x = x.coef

let center x = x.center

let ang_mom x = x.ang_mom

let size x = Array.length x.prim

let normalizations x = x.norm_coef

let norm_scales x = x.norm_coef_scale

let index x = x.index

let size_of_shell x = Array.length x.norm_coef_scale

let primitives x = x.prim

let zkey_array x = Ps.zkey_array x.prim.(0)

let values t point =
  (* Radial part *)
  let r = Co.( point |- t.center ) in
  let r2 = Co.dot r r in
  let radial =
    let rec aux accu = function
    | -1 -> accu
    | i -> let new_accu = 
             t.norm_coef.(i) *. t.coef.(i) *. exp(-. t.expo.(i) *. r2) +. accu
           in aux new_accu (i-1)
    in
    aux 0. (Array.length t.expo - 1)
  in

  (* Angular part *)
  let n = Am.to_int t.ang_mom in
  let x = Array.create_float (n+1) in
  let y = Array.create_float (n+1) in
  let z = Array.create_float (n+1) in
  let fill arr v = 
    arr.(0) <- 1.;
    for i=1 to n do
      arr.(i) <- arr.(i-1) *. v
    done;
  in
  fill x r.x; fill y r.y; fill z r.z;
  let powers =
    Am.zkey_array (Am.Singlet t.ang_mom)
  in
  Array.mapi (fun i a ->
    let p = Zkey.to_int_array a in
    t.norm_coef_scale.(i) *. x.(p.(0)) *. y.(p.(1)) *. z.(p.(2)) *. radial 
    ) powers

  

(** {2 Printers} *)

open Format

(*
let pp_debug ppf x =
  fprintf ppf "@[<2>{@ ";
  fprintf ppf "@[<2>expo =@ %a ;@]@ " pp_float_array_size x.expo;
  fprintf ppf "@[<2>coef =@ %a ;@]@ " pp_float_array_size x.coef;
  fprintf ppf "@[<2>center =@ %a ;@]@ " Co.pp_angstrom x.center;
  fprintf ppf "@[<2>ang_mom =@ %a ;@]@ " Am.pp_string x.ang_mom;
  fprintf ppf "@[<2>norm_coef =@ %a ;@]@ " pp_float_array_size x.norm_coef;
  fprintf ppf "@[<2>norm_coef_scale =@ %a ;@]@ " pp_float_array_size x.norm_coef_scale;
  fprintf ppf "@[<2>index =@ %d ;@]@ " x.index;
  fprintf ppf "}@,@]"
*)

let pp ppf s =
  (match s.ang_mom with
   | Am.S -> fprintf ppf "@[%3d@]    " (s.index+1)
   | _    -> fprintf ppf "@[%3d-%-3d@]" (s.index+1) (s.index+(Array.length s.norm_coef_scale))
  );
  fprintf ppf "@[%a@ %a@]@[" Am.pp_string s.ang_mom Co.pp s.center;
  Array.iter2 (fun e c -> fprintf ppf "@[%16.8e  %16.8e@]@;" e c) s.expo s.coef;
  fprintf ppf "@]"



