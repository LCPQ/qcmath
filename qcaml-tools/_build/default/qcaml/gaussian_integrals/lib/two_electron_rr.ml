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
module Zp   = Zero_m_parameters

let cutoff = Constants.integrals_cutoff 
let cutoff2 = cutoff *. cutoff
  

exception NullQuartet

type four_idx_intermediates =
{
  expo_b : float ;
  expo_d : float ;
  expo_p_inv : float ;
  expo_q_inv : float ;
  center_ab  : Co.t ;
  center_cd  : Co.t ;
  center_pq  : Co.t ;
  center_pa  : Co.t ;
  center_qc  : Co.t ;
  zero_m_array : float array ;
}

(** Horizontal and Vertical Recurrence Relations (HVRR) *)
let rec hvrr_two_e
    angMom_a angMom_b angMom_c angMom_d
    abcd map_1d map_2d =

  (* Swap electrons 1 and 2 so that the max angular momentum is on 1 *)
  if  angMom_a.Po.tot + angMom_b.Po.tot < angMom_c.Po.tot + angMom_d.Po.tot then
    let abcd = {
        expo_b       = abcd.expo_d ;
        expo_d       = abcd.expo_b ;
        expo_p_inv   = abcd.expo_q_inv ;
        expo_q_inv   = abcd.expo_p_inv ;
        center_ab    = abcd.center_cd ;
        center_cd    = abcd.center_ab ;
        center_pq    = Co.neg abcd.center_pq ;
        center_pa    = abcd.center_qc ;
        center_qc    = abcd.center_pa ;
        zero_m_array = abcd.zero_m_array ;
    } in
    hvrr_two_e
      angMom_c angMom_d angMom_a angMom_b
      abcd map_1d map_2d

  else

    let maxm = angMom_a.Po.tot + angMom_b.Po.tot + angMom_c.Po.tot + angMom_d.Po.tot in
    let maxsze = maxm+1 in


    let get_xyz angMom = 
      match angMom with
      | { Po.y=0 ; z=0 ; _ } -> Co.X
      | {          z=0 ; _ } -> Co.Y
      | _                    -> Co.Z
    in

    let expo_p_inv = abcd.expo_p_inv
    and expo_q_inv = abcd.expo_q_inv
    and center_ab  = abcd.center_ab
    and center_cd  = abcd.center_cd
    and center_pq  = abcd.center_pq
    in

    (* Vertical recurrence relations *)
    let rec vrr0 angMom_a = 

      match angMom_a.Po.tot with 
      | 0 -> abcd.zero_m_array
      | _ ->
        let key = Zkey.of_powers_three angMom_a in

        try Zmap.find map_1d key with
        | Not_found ->
          let result = 
            let xyz = get_xyz angMom_a in
            let am    = Po.decr xyz angMom_a in
            let amxyz = Po.get xyz am in

            let f1 = expo_p_inv *. Co.get xyz center_pq
            and f2 = abcd.expo_b *. expo_p_inv *. Co.get xyz center_ab
            in
            let result = Array.create_float (maxsze - angMom_a.Po.tot) in
            if amxyz = 0 then
                begin
                  let v1 = vrr0 am in
                  Array.iteri (fun m _ -> 
                      result.(m) <- f1 *. v1.(m+1)  -. f2 *. v1.(m)) result
                end
            else
                begin
                  let amm = Po.decr xyz am in
                  let v3 = vrr0 amm in
                  let v1 = vrr0 am in
                  let f3 = (Util.float_of_int_fast amxyz) *. expo_p_inv *. 0.5 in
                  Array.iteri (fun m _ ->
                    result.(m) <- f1 *. v1.(m+1) -. f2 *. v1.(m) 
                      +. f3 *. (v3.(m) +. expo_p_inv *. v3.(m+1)) ) result
                end;
            result
          in Zmap.add map_1d key result;
          result


    and vrr angMom_a angMom_c =

      match angMom_a.Po.tot, angMom_c.Po.tot with
      | (i,0) -> if (i>0) then vrr0 angMom_a
                 else abcd.zero_m_array 
      | (_,_) ->
        let key = Zkey.of_powers_six angMom_a angMom_c in

        try Zmap.find map_2d key with
        | Not_found -> 
          let result = 
            (* angMom_c.Po.tot > 0  so cm.Po.tot >= 0 *)
            let xyz   = get_xyz angMom_c in
            let cm    = Po.decr xyz angMom_c in
            let cmxyz = Po.get xyz cm in
            let axyz  = Po.get xyz angMom_a in

            let f1 =
              -. abcd.expo_d *. expo_q_inv *. Co.get xyz center_cd
            and f2 = 
              expo_q_inv *. Co.get xyz center_pq
            in
            let result = Array.make (maxsze - angMom_a.Po.tot - angMom_c.Po.tot) 0. in
            if axyz > 0 then 
                begin
                  let am = Po.decr xyz angMom_a in
                  let f5 = 
                    (Util.float_of_int_fast axyz) *. expo_p_inv *. expo_q_inv *. 0.5 
                  in
                  if (abs_float f5 > cutoff) then 
                    let v5 =
                      vrr am cm 
                    in
                    Array.iteri (fun m _ -> 
                        result.(m) <- result.(m) -.  f5 *. v5.(m+1)) result
                end;
            if cmxyz > 0 then 
                begin
                  let f3 =
                    (Util.float_of_int_fast cmxyz) *. expo_q_inv *. 0.5 
                  in
                  if (abs_float f3 > cutoff) ||
                      (abs_float (f3 *. expo_q_inv) > cutoff) then 
                    begin
                      let v3 = 
                        let cmm = Po.decr xyz cm in
                        vrr angMom_a cmm 
                      in
                      Array.iteri (fun m _ ->
                        result.(m) <- result.(m) +.
                            f3 *. (v3.(m) +. expo_q_inv *. v3.(m+1)) ) result
                    end
                end;
            if ( (abs_float f1 > cutoff) || (abs_float f2 > cutoff) ) then
                begin
                  let v1 = 
                    vrr angMom_a cm 
                  in
                  Array.iteri (fun m _ ->
                    result.(m) <- result.(m) +. f1 *. v1.(m) -.  f2 *. v1.(m+1) ) result
                end;
            result
          in Zmap.add map_2d key result;
          result

    (*
    and trr angMom_a angMom_c =

      match (angMom_a.Po.tot, angMom_c.Po.tot) with
      | (i,0) -> if (i>0) then (vrr0 angMom_a).(0)
                 else abcd.zero_m_array.(0)
      | (_,_) ->
        let key = Zkey.of_powers_six angMom_a angMom_c in

        try (Zmap.find map_2d key).(0) with
        | Not_found -> 
          let result = 
            let xyz   = get_xyz angMom_c in
            let axyz  = Po.get  xyz angMom_a in
            let cm    = Po.decr xyz angMom_c in
            let cmxyz = Po.get  xyz cm       in

            let expo_inv_q_over_p = expo_q_inv /. expo_p_inv in
            let f =
              Co.get xyz center_qc +. expo_inv_q_over_p *.
              Co.get xyz center_pa
            in
            let result = 0. in

            let result = 
              if cmxyz < 1 then result else
                  let f = 0.5 *. (float_of_int_fast cmxyz) *. expo_q_inv in
                  if abs_float f < cutoff then 0.  else
                      let cmm = Po.decr xyz cm in
                      let v3 = trr angMom_a cmm in
                      result +. f *. v3
            in
            let result = 
              if abs_float f < cutoff then result  else
                  let v1 = trr angMom_a cm in
                  result +. f *. v1
            in
            let result = 
              if cmxyz < 0 then result else
                  let f = -. expo_inv_q_over_p in
                  let ap = Po.incr xyz angMom_a in
                  let v4 = trr ap cm in
                  result +. v4 *. f
            in
            let result = 
              if axyz < 1 then result else
                  let f = 0.5 *. (float_of_int_fast axyz) *. expo_q_inv in
                  if abs_float f < cutoff then result else
                      let am = Po.decr xyz angMom_a in
                      let v2 = trr am cm in
                      result +. f *. v2
            in
            result
          in
          Zmap.add map_2d key [|result|];
          result

*)
    in


    let vrr a c = 
        (vrr a c).(0)
        (*
        if maxm < 10 then (vrr a c).(0) else trr a c
        *)
    in


    (* Horizontal recurrence relations *)
    let rec hrr0 angMom_a angMom_b angMom_c =

      match angMom_b.Po.tot with
      | 1 ->
        let xyz  = get_xyz angMom_b in
        let ap = Po.incr xyz angMom_a in
        let v1 = vrr ap angMom_c in
        let f2 = Co.get xyz center_ab in
        if (abs_float f2 < cutoff) then v1 else
            let v2 = vrr angMom_a angMom_c in
            v1 +. f2 *. v2
      | 0 -> vrr angMom_a angMom_c
      | _ ->
        let xyz  = get_xyz angMom_b in
        let bxyz = Po.get xyz angMom_b in
        if bxyz > 0 then 
            let ap = Po.incr xyz angMom_a in
            let bm = Po.decr xyz angMom_b in
            let h1 = hrr0 ap bm angMom_c in
            let f2 = Co.get xyz center_ab in
            if abs_float f2 < cutoff then h1 else
                let h2 = hrr0 angMom_a bm angMom_c in
                h1 +. f2 *. h2
        else 0.


    and hrr angMom_a angMom_b angMom_c angMom_d =

      match (angMom_b.Po.tot, angMom_d.Po.tot) with
      | (_,0) ->
        if (angMom_b.Po.tot = 0) then 
            vrr angMom_a angMom_c
        else
            hrr0 angMom_a angMom_b angMom_c
      | (_,_) ->
        let xyz  = get_xyz angMom_d in
        let cp = Po.incr xyz angMom_c in
        let dm = Po.decr xyz angMom_d in 
        let h1 = hrr angMom_a angMom_b cp dm in
        let f2 = Co.get xyz center_cd in
        if abs_float f2 < cutoff then h1 else
            let h2 = hrr angMom_a angMom_b angMom_c dm in
            h1 +. f2 *. h2

    in
    hrr angMom_a angMom_b angMom_c angMom_d




let contracted_class_shell_pair_couple ?operator ~zero_m shell_pair_couple : float Zmap.t =

    let maxm = Am.to_int (Cspc.ang_mom shell_pair_couple) in

    (* Pre-computation of integral class indices *)
    let class_indices = Cspc.zkey_array shell_pair_couple in

    let contracted_class = 
      Array.make (Array.length class_indices) 0.;
    in

    let monocentric =
      Cspc.monocentric shell_pair_couple
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

        let center_pq = Co.(Psp.center sp_ab |- Psp.center sp_cd) in
        let center_pa = Psp.center_minus_a sp_ab in
        let center_qc = Psp.center_minus_a sp_cd in
        let norm_pq_sq = Co.dot center_pq center_pq in
        let expo_p_inv = Psp.exponent_inv sp_ab in
        let expo_q_inv = Psp.exponent_inv sp_cd in
        let zero = Zp.zero ?operator zero_m in
        let zero_m_array = zero_m
          { zero with
            maxm ; expo_p_inv ; expo_q_inv ; norm_pq_sq ;
            center_pq ; center_pa ; center_qc ; 
          }
        in

        begin
          match Cspc.ang_mom shell_pair_couple with
          | Am.S ->
            let integral = zero_m_array.(0) in
            contracted_class.(0) <- contracted_class.(0) +. coef_prod *. integral
          | _ -> 
            let expo_b = Ps.exponent (Psp.shell_b sp_ab) 
            and expo_d = Ps.exponent (Psp.shell_b sp_cd)
            in
            let map_1d = Zmap.create (4*maxm) 
            and map_2d = Zmap.create (Array.length class_indices)
            in

            (* Compute the integral class from the primitive shell quartet *)
            class_indices
            |> Array.iteri (fun i key ->
                let (angMom_a,angMom_b,angMom_c,angMom_d) =
                  match Zkey.to_powers key with
                  | Zkey.Twelve x -> x
                  | _             -> assert false
                in
                try
                  if monocentric then
                    begin
                      if (  ((1 land angMom_a.Po.x + angMom_b.Po.x + angMom_c.Po.x + angMom_d.Po.x)=1) ||
                            ((1 land angMom_a.Po.y + angMom_b.Po.y + angMom_c.Po.y + angMom_d.Po.y)=1) ||
                            ((1 land angMom_a.Po.z + angMom_b.Po.z + angMom_c.Po.z + angMom_d.Po.z)=1) 
                         ) then
                        raise NullQuartet
                    end;

                  let norm =  norm_scales.(i) in
                  let coef_prod = coef_prod *. norm in

                  let abcd = {
                    expo_b ; expo_d ; expo_p_inv ; expo_q_inv ;
                    center_ab ; center_cd ; center_pq ;
                    center_pa ; center_qc ; zero_m_array ;
                  } in
                  let integral = 
                    hvrr_two_e
                      angMom_a angMom_b angMom_c angMom_d
                      abcd map_1d map_2d 
                  in
                  contracted_class.(i) <- contracted_class.(i) +. coef_prod *. integral
                with NullQuartet -> ()
              )
        end
      ) (Cspc.coefs_and_shell_pair_couples shell_pair_couple);

    let result = 
      Zmap.create (Array.length contracted_class)
    in
    Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
    result








let contracted_class_atomic_shell_pair_couple ?operator ~zero_m atomic_shell_pair_couple : float Zmap.t =

    let maxm = Am.to_int (Aspc.ang_mom atomic_shell_pair_couple) in

    (* Pre-computation of integral class indices *)
    let class_indices = Aspc.zkey_array atomic_shell_pair_couple in

    let contracted_class = 
      Array.make (Array.length class_indices) 0.;
    in

    let monocentric =
      Aspc.monocentric atomic_shell_pair_couple
    in

    let shell_p = Aspc.atomic_shell_pair_p atomic_shell_pair_couple
    and shell_q = Aspc.atomic_shell_pair_q atomic_shell_pair_couple
    in

    (* Compute all integrals in the shell for each pair of significant shell pairs *)

    let center_ab = Asp.a_minus_b shell_p
    and center_cd = Asp.a_minus_b shell_q
    in

    let norm_scales = Aspc.norm_scales atomic_shell_pair_couple in


    List.iter (fun cspc ->
      List.iter (fun (coef_prod, spc) ->
        let sp_ab = Pspc.shell_pair_p spc
        and sp_cd = Pspc.shell_pair_q spc
        in

        let expo_p_inv = Psp.exponent_inv sp_ab
        in

        let center_pq = Co.(Psp.center sp_ab |- Psp.center sp_cd) in
        let center_qc = Psp.center_minus_a sp_cd in
        let center_pa = Psp.center_minus_a sp_ab in
        let norm_pq_sq = Co.dot center_pq center_pq in
        let expo_q_inv = Psp.exponent_inv sp_cd in

        let zero = Zp.zero ?operator zero_m in
        let zero_m_array = zero_m
          { zero with
            maxm ; expo_p_inv ; expo_q_inv ; norm_pq_sq ;
            center_pq ; center_pa ; center_qc ; 
          }
        in

        begin
          match Aspc.ang_mom atomic_shell_pair_couple with
          | Am.S ->
            let integral = zero_m_array.(0) in
            contracted_class.(0) <- contracted_class.(0) +. coef_prod *. integral
          | _ -> 
            let expo_b = Ps.exponent (Psp.shell_b sp_ab) 
            and expo_d = Ps.exponent (Psp.shell_b sp_cd)
            in
            let map_1d = Zmap.create (4*maxm) 
            and map_2d = Zmap.create (Array.length class_indices)
            in

            (* Compute the integral class from the primitive shell quartet *)
            class_indices
            |> Array.iteri (fun i key ->
                let (angMom_a,angMom_b,angMom_c,angMom_d) =
                  match Zkey.to_powers key with
                  | Zkey.Twelve x -> x
                  | _             -> assert false
                in
                try
                  if monocentric then
                    begin
                      if (  ((1 land angMom_a.Po.x + angMom_b.Po.x + angMom_c.Po.x + angMom_d.Po.x)=1) ||
                            ((1 land angMom_a.Po.y + angMom_b.Po.y + angMom_c.Po.y + angMom_d.Po.y)=1) ||
                            ((1 land angMom_a.Po.z + angMom_b.Po.z + angMom_c.Po.z + angMom_d.Po.z)=1) 
                         ) then
                        raise NullQuartet
                    end;

                  let norm =  norm_scales.(i) in
                  let coef_prod = coef_prod *. norm in

                  let abcd = {
                    expo_b ; expo_d ; expo_p_inv ; expo_q_inv ;
                    center_ab ; center_cd ; center_pq ;
                    center_pa ; center_qc ; zero_m_array ;
                  } in
                  let integral = 
                    hvrr_two_e
                      angMom_a angMom_b angMom_c angMom_d
                      abcd
                      map_1d map_2d 
                  in
                  contracted_class.(i) <- contracted_class.(i) +. coef_prod *. integral
                with NullQuartet -> ()
              )
        end
        ) (Cspc.coefs_and_shell_pair_couples cspc)
      ) (Aspc.contracted_shell_pair_couples atomic_shell_pair_couple);

    let result = 
      Zmap.create (Array.length contracted_class)
    in
    Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
    result

