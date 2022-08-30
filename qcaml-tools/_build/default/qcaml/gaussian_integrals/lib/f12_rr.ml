open Common
open Gaussian

module Am   = Angular_momentum
module Asp  = Atomic_shell_pair
module Aspc = Atomic_shell_pair_couple
module Co   = Coordinate
module Cs   = Contracted_shell
module Csp  = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple
module Po   = Powers
module Psp  = Primitive_shell_pair
module Pspc = Primitive_shell_pair_couple
module Ps   = Primitive_shell

let cutoff = Constants.integrals_cutoff 
let cutoff2 = cutoff *. cutoff

exception NullQuartet

type four_idx_intermediates =
  {
    zero         : float array array;
    gp           : float array;
    gg           : float array;
    gq           : float array;
    coef_g       : float array ;
    center_ra    : Co.t array ;
    center_rc    : Co.t array ;
    center_ab    : Co.t  ;
    center_cd    : Co.t  ;
  }
  
(** Horizontal and Vertical Recurrence Relations (HVRR) *)
let hvrr angMom_a angMom_b angMom_c angMom_d
    abcd map_x map_y map_z =
  
  let gp   = abcd.gp   in
  let gg   = abcd.gg   in
  let gq   = abcd.gq   in
  
  let coef_g = abcd.coef_g in
  
  let run xyz map =
    
    let zero =
      match xyz with
      | Co.X -> abcd.zero.(0)
      | Co.Y -> abcd.zero.(1)
      | Co.Z -> abcd.zero.(2)
    in
    let angMom_a  = Po.get xyz angMom_a in
    let angMom_b  = Po.get xyz angMom_b in
    let angMom_c  = Po.get xyz angMom_c in
    let angMom_d  = Po.get xyz angMom_d in
    let center_ab = Co.get xyz abcd.center_ab in
    let center_cd = Co.get xyz abcd.center_cd in
    let center_ra = Array.map (fun x -> Co.get xyz x) abcd.center_ra in
    let center_rc = Array.map (fun x -> Co.get xyz x) abcd.center_rc in
    
    let rec vrr angMom_a angMom_c = 
      match angMom_a, angMom_c with
      | 0, -1
      | -1, 0 -> assert false
      | 0, 0 -> zero
      | 1, 0 -> 
          let v1 = zero in
          Array.mapi (fun i v1i -> center_ra.(i) *. v1i ) v1
      | 0, 1 -> 
          let v1 = zero in
          Array.mapi (fun i v1i -> center_rc.(i) *.  v1i ) v1
      | 1, 1 -> 
          let v1 = vrr 1 0 in
          let v2 = zero in
          Array.mapi (fun i v1i -> center_rc.(i) *.  v1i +.
                                   gg.(i) *. v2.(i) ) v1
      | 2, 0 -> 
          let v1 = vrr 1 0 in
          let v2 = zero in
          Array.mapi (fun i v1i -> center_ra.(i) *. v1i +. gp.(i) *. v2.(i)) v1
      | _, 0 -> 
          let v1 = 
            vrr (angMom_a-1) 0
          in
          let a = Util.float_of_int_fast (angMom_a-1) in
          let v2 = 
            vrr (angMom_a-2) 0
          in
          Array.mapi (fun i v1i -> center_ra.(i) *. v1i +. a *. gp.(i) *. v2.(i)) v1
      | _, 1 -> 
          let v1 = 
            vrr angMom_a 0
          in
          let a = Util.float_of_int_fast angMom_a in
          let v2 = 
            vrr (angMom_a-1) 0
          in
          Array.mapi (fun i v1i -> center_rc.(i) *.  v1i +.
                                   a *. gg.(i) *. v2.(i) ) v1
      | 0, _ -> 
          let v1 = 
            vrr 0 (angMom_c-1)
          in
          let b = Util.float_of_int_fast (angMom_c-1) in
          let v3 = 
            vrr 0 (angMom_c-2)
          in
          Array.mapi (fun i v1i -> center_rc.(i) *.  v1i +.
                                   b *. gq.(i) *. v3.(i)) v1
      | _ -> 
          let v1 = 
            vrr angMom_a (angMom_c-1)
          in
          let a = Util.float_of_int_fast angMom_a in
          let b = Util.float_of_int_fast (angMom_c-1) in
          let v2 = 
            vrr (angMom_a-1) (angMom_c-1)
          in
          let v3 = 
            vrr angMom_a (angMom_c-2)
          in
          Array.mapi (fun i v1i -> center_rc.(i) *.  v1i +.
                                   a *. gg.(i) *. v2.(i) +.  b *. gq.(i) *. v3.(i)) v1
    in
    
    let rec hrr angMom_a angMom_b angMom_c angMom_d =
      let key = Zkey.of_int_four angMom_a angMom_b angMom_c angMom_d in
      
      try Zmap.find map key with
      | Not_found -> 
          let result = 
            match angMom_b, angMom_d with
            | -1, 0 
            | 0, -1 -> assert false 
            | 0, 0 ->
                vrr angMom_a angMom_c
            | _, 0 -> 
                let h1 = 
                  hrr (angMom_a+1) (angMom_b-1) angMom_c angMom_d 
                in
                if center_ab = 0. then
                  h1
                else
                  let h2 = 
                    hrr angMom_a (angMom_b-1) angMom_c angMom_d 
                  in
                  Array.mapi (fun i h1i -> h1i +. center_ab *. h2.(i)) h1
            | _ -> 
                let h1 = 
                  hrr angMom_a angMom_b (angMom_c+1) (angMom_d-1)
                in
                if center_cd = 0. then
                  h1
                else
                  let h2 = 
                    hrr angMom_a angMom_b angMom_c (angMom_d-1) 
                  in
                  Array.mapi (fun i h1i -> h1i +. center_cd *. h2.(i)) h1
          in (Zmap.add map key result; result)
             
    in
    hrr angMom_a angMom_b angMom_c angMom_d
  in
  let x, y, z = 
    (run Co.X map_x), (run Co.Y map_y), (run Co.Z map_z)
  in
  let rec aux accu = function
    | 0 -> accu +. coef_g.(0) *. x.(0) *. y.(0) *. z.(0)
    | i -> (aux [@tailcall]) (accu +. coef_g.(i) *. x.(i) *. y.(i) *. z.(i)) (i-1)
  in
  aux 0. (Array.length x - 1)
    
    
let contracted_class_shell_pair_couple expo_g_inv coef_g shell_pair_couple : float Zmap.t =
  
  (* Pre-computation of integral class indices *)
  let class_indices = Cspc.zkey_array shell_pair_couple in
  
  let contracted_class = 
    Array.make (Array.length class_indices) 0.;
  in
  
  (* Compute all integrals in the shell for each pair of significant shell pairs *)
  
  let shell_p = Cspc.shell_pair_p shell_pair_couple
  and shell_q = Cspc.shell_pair_q shell_pair_couple
  in
  
  let center_ab = Csp.a_minus_b shell_p
  and center_cd = Csp.a_minus_b shell_q
  in
  
  let norm_scales = Cspc.norm_scales shell_pair_couple in
  
  List.iter (fun (coef_prod, spc) ->
    
    let sp_ab = Pspc.shell_pair_p spc
    and sp_cd = Pspc.shell_pair_q spc
    in
    
    let expo_p_inv = Psp.exponent_inv sp_ab in
    let expo_q_inv = Psp.exponent_inv sp_cd in
    let expo_pgq = Array.map (fun e -> 
      1. /. (expo_p_inv +. expo_q_inv +. e)
    ) expo_g_inv
    in
    
    let fp = Array.map (fun e -> expo_p_inv *. e) expo_pgq in
    let fq = Array.map (fun e -> expo_q_inv *. e) expo_pgq in
    
    let gp =
      let x = 0.5 *. expo_p_inv in
      Array.map (fun f -> (1. -. f) *. x) fp
    in
    let gq =
      let x = 0.5 *. expo_q_inv in
      Array.map (fun f -> (1. -. f) *. x) fq
    in
    let gg =
      let x = 0.5 *. expo_q_inv in
      Array.map (fun f -> f *. x) fp
    in
    
    let center_pq = Co.(Psp.center sp_ab |- Psp.center sp_cd) in
    let center_qc = Psp.center_minus_a sp_cd in
    let center_pa = Psp.center_minus_a sp_ab in
    
    let center_ra = Array.map (fun f -> Co.(center_pa |- (f |. center_pq))) fp in
    let center_rc = Array.map (fun f -> Co.(center_qc |+ (f |. center_pq))) fq in
    
    (* zero_m is defined here *)
    let zero = Array.map (fun xyz ->
      let x = Co.get xyz center_pq in
      Array.mapi (fun i ei ->
        let fg = expo_g_inv.(i) *. ei in
        (sqrt fg) *. exp (-. x *. x *. ei )) expo_pgq
    ) Co.[| X ; Y ; Z |]
    in
    begin
      match Cspc.ang_mom shell_pair_couple with
          (*
          | Am.S ->
            let integral =
              zero.(0) *. zero.(1) *. zero.(2)
            in
            contracted_class.(0) <- contracted_class.(0) +. coef_prod *. integral 
            *)
      | _ -> 
          let map_x, map_y, map_z =
            Zmap.create (Array.length class_indices),
            Zmap.create (Array.length class_indices),
            Zmap.create (Array.length class_indices)
          in
          (* Compute the integral class from the primitive shell quartet *)
          class_indices
          |> Array.iteri (fun i key ->
            let (angMom_a,angMom_b,angMom_c,angMom_d) =
              match Zkey.to_powers key with
              | Zkey.Twelve x -> x
              | _             -> assert false
            in
            let norm =  norm_scales.(i) in
            let coef_prod = coef_prod *. norm in
            let abcd = {
              zero ; gp ; gg ; gq ; 
              center_ab ; center_cd ; 
              center_ra ; center_rc ;
              coef_g ;
            } in
            let integral = 
              hvrr
                angMom_a angMom_b angMom_c angMom_d
                abcd map_x map_y map_z
            in
            contracted_class.(i) <- contracted_class.(i) +. coef_prod *. integral 
          )
    end
  ) (Cspc.coefs_and_shell_pair_couples shell_pair_couple);
  
  let result = 
    Zmap.create (Array.length contracted_class)
  in
  
  
  Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
  result
  
