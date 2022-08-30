open Common
open Particles
open Util
open Constants
open Gaussian

exception NullPair

module Am  = Angular_momentum
module Co  = Coordinate
module Cs  = Contracted_shell
module Csp = Contracted_shell_pair
module Po  = Powers
module Ps  = Primitive_shell
module Psp = Primitive_shell_pair



(** Horizontal and Vertical Recurrence Relations (HVRR) *)
let hvrr_one_e  angMom_a  angMom_b  
    zero_m_array expo_inv_p
    center_ab center_pa center_pc
    map =

  let maxm = angMom_a.Po.tot + angMom_b.Po.tot  in
  let maxsze = maxm+1 in

  let get_xyz angMom =
    match angMom with
    | { Po.y=0 ; z=0 ; _ } -> Co.X
    | {          z=0 ; _ } -> Co.Y
    | _                    -> Co.Z
  in


  (* Vertical recurrence relations *)
  let rec vrr angMom_a =
    let { Po.x=ax ; y=ay ; z=az ; _ } = angMom_a in
    if ax < 0 || ay < 0 || az < 0 then raise Exit
    else
      match angMom_a.Po.tot  with
      | 0 -> zero_m_array
      | _ ->
        let key = Zkey.of_powers_three angMom_a in

        try Zmap.find map key with
        | Not_found -> 
          let result = 
            let xyz   = get_xyz angMom_a in
            let am    = Po.decr xyz angMom_a in
            let amxyz = Po.get xyz am in
            let f1    = Co.get xyz center_pa  in
            let f2    = expo_inv_p *. Co.get xyz center_pc in
            if amxyz < 1 then
                let v1 = vrr am in
                Array.init (maxsze - angMom_a.Po.tot)
                  (fun m -> f1 *. v1.(m) -. f2 *. v1.(m+1))
            else
                let v3 =
                  let amm = Po.decr xyz am in
                  vrr amm
                in
                let v1 = vrr am in
                let f3 = float_of_int_fast amxyz *. expo_inv_p *. 0.5 in
                Array.init (maxsze - angMom_a.Po.tot)
                  (fun m -> f1 *. v1.(m) -.  f2 *. v1.(m+1) +.
                            f3 *. (v3.(m) -. expo_inv_p *. v3.(m+1))
                )
          in Zmap.add map key result;
          result


  (* Horizontal recurrence relations *)
  and hrr angMom_a angMom_b =

    match angMom_b.Po.tot  with
    | 0 -> (vrr angMom_a).(0)
    | _ ->
      let xyz = get_xyz angMom_b in
      let bxyz = Po.get xyz angMom_b in
      if (bxyz < 1) then 0. else
          let ap = Po.incr xyz angMom_a in
          let bm = Po.decr xyz angMom_b in
          let h1 = hrr ap bm in
          let f2 = Co.get xyz center_ab in
          if abs_float f2 < integrals_cutoff then h1 else
              let h2 = hrr angMom_a bm in
              h1 +. f2 *. h2

  in
  hrr angMom_a angMom_b









(** Computes all the one-electron integrals of the contracted shell pair *)
let contracted_class_shell_pair ~zero_m shell_p geometry : float Zmap.t =

  let shell_a = Csp.shell_a shell_p
  and shell_b = Csp.shell_b shell_p
  in
  let maxm = Am.to_int (Csp.ang_mom shell_p) in

  (* Pre-computation of integral class indices *)
  let class_indices = Csp.zkey_array shell_p in

  let contracted_class = 
    Array.make (Array.length class_indices) 0.;
  in

  (* Compute all integrals in the shell for each pair of significant shell pairs *)

  let norm_scales_p = Csp.norm_scales shell_p in

  let center_ab = Csp.a_minus_b shell_p  in

  List.iter (fun (coef_prod, psp) ->
    try
      begin
        (* Screening on the product of coefficients *)
        if abs_float coef_prod < 1.e-3 *. integrals_cutoff then
          raise NullPair;

        let expo_pq_inv = Psp.exponent_inv psp 
        and center_p = Psp.center psp 
        and center_pa = Psp.center_minus_a psp
        in
        
        Array.iter (fun (element, nucl_coord) ->
          let charge = Element.to_charge element |> Charge.to_float in
          let center_pc =
            Co.(center_p |- nucl_coord ) 
          in
          let norm_pq_sq = 
            Co.dot center_pc center_pc
          in

          let zero_m_array = 
            zero_m ~maxm ~expo_pq_inv ~norm_pq_sq
          in
          match Cs.(ang_mom shell_a, ang_mom shell_b) with
          | Am.(S,S) -> 
            let integral = zero_m_array.(0) in
            contracted_class.(0) <- contracted_class.(0) -. coef_prod *. integral *. charge
          | _ ->
            let map = Zmap.create (2*maxm) in
            let norm_scales = norm_scales_p in
            (* Compute the integral class from the primitive shell quartet *)
            class_indices
            |> Array.iteri (fun i key ->
                let (angMomA,angMomB) =
                  match Zkey.to_powers key with
                  | Zkey.Six x -> x
                  | _          -> assert false
                in
                let norm = norm_scales.(i) in
                let coef_prod = coef_prod *. norm in
                let integral = 
                  hvrr_one_e
                    angMomA  angMomB
                    zero_m_array
                    expo_pq_inv
                    center_ab center_pa center_pc
                    map
                in
                contracted_class.(i) <- contracted_class.(i) -. coef_prod *. integral *. charge
              )
      ) geometry
  end
  with NullPair -> ()
  ) (Csp.coefs_and_shell_pairs shell_p);

  let result = 
    Zmap.create (Array.length contracted_class)
  in
  Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
  result



