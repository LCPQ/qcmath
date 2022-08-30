open Common
open Gaussian
open Linear_algebra

module Am   = Angular_momentum
module Co   = Coordinate
module Cs   = Contracted_shell
module Csp  = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple
module Po   = Powers
module Psp  = Primitive_shell_pair
module Ps   = Primitive_shell
module Zp   = Zero_m_parameters

exception NullQuartet
exception Found

let cutoff = Constants.integrals_cutoff 
let cutoff2 = cutoff *. cutoff
let empty = Zmap.create 0

let at_least_one_valid arr =
  try
    Array.iter (fun x -> if (abs_float x > cutoff) then raise Found) arr ; false
  with Found -> true

type four_idx_intermediate =
{
  expo_b : float array;
  expo_d : float array;
  expo_p_inv : float array;
  expo_q_inv : float array;
  center_ab  : Co.t ;
  center_cd  : Co.t ;
  center_pq  : Co.axis -> float array array;
  center_pa  : Co.axis -> float array;
  center_qc  : Co.axis -> float array;
  zero_m_array : float array array array;
}



(** Horizontal and Vertical Recurrence Relations (HVRR) *)
let hvrr_two_e_vector (angMom_a, angMom_b, angMom_c, angMom_d)
    abcd map_1d map_2d np nq
  =

  let expo_p_inv   = abcd.expo_p_inv
  and expo_q_inv   = abcd.expo_q_inv
  and center_ab    = abcd.center_ab 
  and center_cd    = abcd.center_cd 
  and center_pq    = abcd.center_pq 
  in

  let zero_m_array = abcd.zero_m_array in

  let maxm = Array.length zero_m_array - 1 in

  let get_xyz angMom = 
    match angMom with
    | { Po.y=0 ; z=0 ; _ } -> Co.X
    | {          z=0 ; _ } -> Co.Y
    | _                    -> Co.Z
  in

  (* Vertical recurrence relations *)
  let rec vrr0_v angMom_a = 
    match angMom_a.Po.tot with
    | 0 -> zero_m_array
    | _ ->
      let key = Zkey.of_powers_three angMom_a
      in

      try Zmap.find map_1d key with
      | Not_found -> 
        let result = 
          let xyz = get_xyz angMom_a in
          let am  = Po.decr xyz angMom_a in
          let cab = Co.get xyz center_ab in
          let result = Array.init (maxm+1-angMom_a.Po.tot) (fun _ -> Array.make_matrix np nq 0.) in
          let v_am= vrr0_v am in

          begin
            if abs_float cab >= cutoff then
                let expo_b = abcd.expo_b  in
                Array.iteri (fun m result_m -> 
                    let v0 = v_am.(m) in
                    Array.iteri (fun l result_ml ->
                        let f0 = -. expo_b.(l) *. expo_p_inv.(l) *. cab
                        and v0_l = v0.(l) 
                        in
                        Array.iteri (fun k v0_lk ->
                            result_ml.(k) <- v0_lk *. f0) v0_l
                    ) result_m
                ) result
          end;
          let amxyz = Po.get  xyz am in
          if amxyz < 1 then
              Array.iteri (fun l expo_inv_p_l ->
                  let center_pq_xyz_l = (center_pq xyz).(l) in
                  Array.iteri (fun m result_m -> 
                        let result_ml = result_m.(l) in
                        let p0  = v_am.(m+1) in
                        let p0_l = p0.(l)
                        in
                        Array.iteri (fun k p0_lk ->
                            result_ml.(k) <- result_ml.(k)
                                            +. expo_inv_p_l *. center_pq_xyz_l.(k) *. p0_lk
                          ) p0_l
                      ) result
                ) expo_p_inv
          else
              begin
                let amm = Po.decr xyz am in
                let amxyz = Util.float_of_int_fast amxyz  in
                let v_amm = vrr0_v amm in
                Array.iteri (fun l expo_inv_p_l ->
                    let f = amxyz *. expo_p_inv.(l) *. 0.5 
                    and center_pq_xyz_l = (center_pq xyz).(l)
                    in
                    Array.iteri (fun m result_m ->
                        let v1 = v_amm.(m) in
                        let v1_l = v1.(l) in
                        let result_ml = result_m.(l) in
                        let v2 = v_amm.(m+1)  in
                        let p0  = v_am.(m+1) in
                        let v2_l = v2.(l)
                        in
                        Array.iteri (fun k p0_lk ->
                            result_ml.(k) <- result_ml.(k) +.
                                            expo_inv_p_l *. center_pq_xyz_l.(k) *. p0_lk +.
                                            f *. (v1_l.(k) +. v2_l.(k) *. expo_inv_p_l) 
                          ) p0.(l)
                        ) result
                ) expo_p_inv
              end;
          result 
        in
        Zmap.add map_1d key result;
        result

  and vrr_v m angMom_a angMom_c =

    match (angMom_a.Po.tot, angMom_c.Po.tot) with
    | (_,0) -> Some (vrr0_v angMom_a).(m)
    | (_,_) ->

      let key =  Zkey.of_powers_six angMom_a angMom_c in

      try Zmap.find map_2d.(m) key with
      | Not_found -> 
        let result = 
          begin
            let xyz = get_xyz angMom_c in
            let cm = Po.decr xyz angMom_c in
            let axyz  = Po.get xyz angMom_a in

            let do_compute = ref false in
            let v1 =
              let f = -. (Co.get xyz center_cd) in

              let f1 =
                let expo_d = abcd.expo_d in
                Array.init nq (fun k ->
                    let x = expo_d.(k) *. expo_q_inv.(k) *. f in
                    if ( (not !do_compute) && (abs_float x > cutoff) ) then
                      do_compute := true;
                    x)
              in
              if (!do_compute) then
                match vrr_v m angMom_a cm with
                | None -> None
                | Some v1 -> 
                  begin
                    Some (Array.init np (fun l ->
                      let v1_l = v1.(l) in
                      Array.mapi (fun k f1k -> v1_l.(k) *. f1k) f1
                    ) )
                  end
              else None
            in

            let v2 =
              let f2 =
                Array.init np (fun l ->
                    let cpq_l = (center_pq xyz).(l) in
                    Array.init nq (fun k ->
                        let x = expo_q_inv.(k) *. cpq_l.(k) in
                        if (!do_compute) then x
                        else (if abs_float x > cutoff then do_compute := true ; x)
                      ) )
              in
              if (!do_compute) then
                match vrr_v (m+1) angMom_a cm with
                | None -> None
                | Some v2 -> 
                  begin
                    for l=0 to np-1 do
                      let f2_l = f2.(l)
                      and v2_l = v2.(l)
                      in
                      for k=0 to nq-1 do
                        f2_l.(k) <- -. v2_l.(k) *. f2_l.(k)
                      done
                    done;
                    Some f2
                  end
              else None
            in

            let p1 = 
              match v1, v2 with
              | None, None -> None
              | None, Some v2 -> Some v2
              | Some v1, None -> Some v1
              | Some v1, Some v2 ->
                begin
                  for l=0 to np-1 do
                    let v1_l = v1.(l)
                    and v2_l = v2.(l)
                    in
                    for k=0 to nq-1 do
                      v2_l.(k) <- v2_l.(k) +. v1_l.(k)
                    done
                  done;
                  Some v2
                end
            in

            let cxyz = Po.get  xyz angMom_c in
            let p2 = 
              if cxyz < 2 then p1 else
                let cmm = Po.decr xyz cm in
                let fcm = (Util.float_of_int_fast (cxyz-1)) *. 0.5 in
                let f1 =
                  Array.init nq (fun k ->
                      let x = fcm *. expo_q_inv.(k) in
                      if (!do_compute) then x
                      else (if abs_float x > cutoff then do_compute := true ; x)
                    )
                in
                let v1 = 
                  if (!do_compute) then
                    match vrr_v m angMom_a cmm with
                    | None -> None
                    | Some v1 -> 
                      begin
                        let result = Array.make_matrix np nq 0. in
                        for l=0 to np-1 do
                          let v1_l = v1.(l)
                          and result_l = result.(l)
                          in
                          for k=0 to nq-1 do
                            result_l.(k) <- v1_l.(k) *. f1.(k)
                          done;
                        done;
                        Some result
                      end
                  else None
                in

                let v3 = 
                  let f2 = 
                    Array.init nq (fun k -> 
                        let x = expo_q_inv.(k) *. f1.(k) in
                        if (!do_compute) then x
                        else (if abs_float x > cutoff then do_compute := true ; x)
                      )
                  in
                  if (!do_compute) then
                    match vrr_v (m+1) angMom_a cmm with
                    | None -> None
                    | Some v3 -> 
                      begin
                        let result = Array.make_matrix np nq 0. in
                        for l=0 to np-1 do
                          let v3_l = v3.(l)
                          and result_l = result.(l)
                          in
                          for k=0 to nq-1 do
                            result_l.(k) <- v3_l.(k) *. f2.(k)
                          done
                        done;
                        Some result
                      end
                  else None
                in
                match p1, v1, v3 with
                | None, None, None    -> None
                | Some p1, None, None -> Some p1
                | None, Some v1, None -> Some v1
                | None, None, Some v3 -> Some v3
                | Some p1, Some v1, Some v3 ->
                  begin
                    for l=0 to np-1 do
                      let v3_l = v3.(l)
                      and v1_l = v1.(l)
                      and p1_l = p1.(l)
                      in
                      for k=0 to nq-1 do
                        v3_l.(k) <- p1_l.(k) +. v1_l.(k) +. v3_l.(k)
                      done
                    done;
                    Some v3
                  end
                | Some p1, Some v1, None ->
                  begin
                    for l=0 to np-1 do
                      let v1_l = v1.(l)
                      and p1_l = p1.(l)
                      in
                      for k=0 to nq-1 do
                        p1_l.(k) <- v1_l.(k) +. p1_l.(k)
                      done
                    done;
                    Some p1
                  end
                | Some p1, None, Some v3 ->
                  begin
                    for l=0 to np-1 do
                      let v3_l = v3.(l)
                      and p1_l = p1.(l)
                      in
                      for k=0 to nq-1 do
                        p1_l.(k) <- p1_l.(k) +. v3_l.(k)
                      done
                    done;
                    Some p1
                  end
                | None   , Some v1, Some v3 ->
                  begin
                    for l=0 to np-1 do
                      let v3_l = v3.(l)
                      and v1_l = v1.(l)
                      in
                      for k=0 to nq-1 do
                        v3_l.(k) <- v1_l.(k) +. v3_l.(k)
                      done
                    done;
                    Some v3
                  end
            in
            if (axyz < 1) || (cxyz < 1) then p2 else
              let am = Po.decr xyz angMom_a in
              let v = 
                vrr_v (m+1) am cm
              in
              match (p2, v) with
              | None, None   -> None
              | Some p2, None -> Some p2
              | _, Some v ->
                begin
                  let p2 =
                    match p2 with
                    | None -> Array.make_matrix np nq 0.
                    | Some p2 -> p2
                  in
                  for l=0 to np-1 do
                    let fa = (Util.float_of_int_fast axyz) *. expo_p_inv.(l) *. 0.5 in
                    let p2_l = p2.(l)
                    and v_l = v.(l)
                    in
                    for k=0 to nq-1 do
                      p2_l.(k) <- p2_l.(k) -. fa *. expo_q_inv.(k) *. v_l.(k)
                    done
                  done;
                  Some p2
                end
          end
        in Zmap.add map_2d.(m) key result;
        result

(*
  and trr_v angMom_a angMom_c =

    match (angMom_a.Po.tot, angMom_c.Po.tot) with
    | (i,0) -> Some (vrr0_v angMom_a).(0)
    | (_,_) ->

      let key =  Zkey.of_powers_six angMom_a angMom_c in

      try Zmap.find map_2d.(0) key with
      | Not_found -> 
          let xyz   = get_xyz angMom_c in
          let axyz  = Po.get  xyz angMom_a in
          let cm    = Po.decr xyz angMom_c in
          let cmxyz = Po.get  xyz cm       in
          let expo_inv_q_over_p =
            Array.mapi (fun l expo_inv_p_l ->
              let expo_p_l = 1./.expo_inv_p_l in
              Array.mapi (fun k expo_inv_q_k ->
                expo_inv_q_k *. expo_p_l) expo_q_inv ) expo_p_inv
          in
          let result = None in

          let result =
            if cmxyz < 1 then result else
              begin
                let f = 0.5 *. (float_of_int_fast cmxyz)  in
                let cmm = Po.decr xyz cm in
                match result, trr_v angMom_a cmm with
                | None, None -> None
                | None, Some v3 ->
                    Some (Array.init np (fun l ->
                      let v3_l = v3.(l) in
                      Array.mapi  (fun k v3_lk ->
                        expo_q_inv.(k) *. f *. v3_lk) v3_l
                    ) )
                | Some result, None -> Some result
                | Some result, Some v3 ->
                    (Array.iteri (fun l v3_l ->
                      let result_l = result.(l) in
                      Array.iteri (fun k v3_lk ->
                      result_l.(k) <- result_l.(k) +.
                        expo_q_inv.(k) *. f *. v3_lk) v3_l
                    ) v3 ; Some result)
              end
          in
          let result =
            begin
              match result, trr_v angMom_a cm with
              | Some result, None -> Some result
              | Some result, Some v1 ->
                    (Array.iteri (fun l v1_l ->
                      let cpa = (center_pa xyz).(l)
                      and result_l = result.(l)
                      and expo_inv_q_over_p_l = expo_inv_q_over_p.(l)
                      in
                      Array.iteri (fun k v1_lk -> 
                        let cqc = (center_qc xyz).(k) in
                        result_l.(k) <- result_l.(k) +.
                        (cqc +. expo_inv_q_over_p_l.(k) *. cpa) *. v1_lk 
                      ) v1_l
                    ) v1 ; Some result)
              | None, None -> None
              | None, Some v1 ->
                    Some (Array.init np (fun l ->
                      let v1_l = v1.(l) 
                      and cpa = (center_pa xyz).(l)
                      and expo_inv_q_over_p_l = expo_inv_q_over_p.(l)
                      in
                      Array.mapi (fun k v1_lk ->
                        let cqc = (center_qc xyz).(k) in
                        (cqc +. expo_inv_q_over_p_l.(k) *. cpa) *. v1_lk 
                      ) v1_l
                    ) )
            end
          in
          let result =
            if cmxyz < 0 then result else
              begin
                let ap = Po.incr xyz angMom_a in
                match result, trr_v ap cm with
                | Some result, None -> Some result
                | Some result, Some v4 ->
                    (Array.iteri (fun l v4_l ->
                      let result_l = result.(l) in
                      Array.iteri (fun k v4_lk ->
                      let expo_inv_q_over_p_l = expo_inv_q_over_p.(l) in
                      result_l.(k) <- result_l.(k) 
                        -. expo_inv_q_over_p_l.(k) *. v4_lk) v4_l
                    ) v4 ; Some result)
                | None, None -> None
                | None, Some v4 ->
                    Some (Array.init np (fun l ->
                      let v4_l = v4.(l) in
                      let expo_inv_q_over_p_l = expo_inv_q_over_p.(l) in
                      Array.mapi  (fun k v4_lk ->
                        -. expo_inv_q_over_p_l.(k) *. v4_lk) v4_l
                    ) )
              end
          in
          let result =
            if axyz < 1 then result else
              begin
                let f = 0.5 *. (float_of_int_fast axyz)  in
                let am = Po.decr xyz angMom_a in
                match result, trr_v am cm with
                | Some result, None -> Some result
                | Some result, Some v2 ->
                    (Array.iteri (fun l v2_l ->
                      let result_l = result.(l) in
                      Array.iteri (fun k v2_lk ->
                      result_l.(k) <- result_l.(k) +.
                        expo_q_inv.(k) *. f *. v2_lk) v2_l
                    ) v2; Some result)
                | None, None -> None
                | None, Some v2 ->
                    Some (Array.init np (fun l ->
                      let v2_l = v2.(l) in
                      Array.mapi  (fun k v2_lk ->
                        expo_q_inv.(k) *. f *. v2_lk) v2_l
                    ) )
              end
          in
          Zmap.add map_2d.(0) key result;
          result
          *)
  in

  let sum matrix =
    Array.fold_left (fun accu c -> accu +. Array.fold_left (+.) 0. c) 0. matrix
  in

  let vrr_v a c = 
    let v = 
      (*
      if c.Po.tot <> 0 then
        vrr_v 0 a c
      else trr_v a c
      *)
      vrr_v 0 a c
    in
    match v with 
      | Some matrix -> sum matrix
      | None -> 0.
  in


  (* Horizontal recurrence relations *)
  let rec hrr0_v angMom_a angMom_b angMom_c =

    match angMom_b.Po.tot with
    | 0 ->
      begin
        match (angMom_a.Po.tot, angMom_c.Po.tot) with
        | (0,0) -> sum zero_m_array.(0)
        | (_,_) -> vrr_v angMom_a angMom_c
      end
    | 1 ->
      let xyz  = get_xyz angMom_b in
      let ap = Po.incr xyz angMom_a in
      let f  = Co.get xyz center_ab in
      let v1 = vrr_v ap angMom_c in
      if (abs_float f < cutoff) then v1 else
          let v2 = vrr_v angMom_a angMom_c in
          v1 +. v2 *. f
    | _ ->
      let xyz  = get_xyz angMom_b in
      let bxyz = Po.get xyz angMom_b in
      if (bxyz < 0) then 0. else
          let ap = Po.incr xyz angMom_a in
          let bm = Po.decr xyz angMom_b in
          let h1 = hrr0_v ap bm angMom_c in
          let f = Co.get xyz center_ab in
          if abs_float f < cutoff then h1 else
              let h2 = hrr0_v angMom_a bm angMom_c in
              h1 +. h2 *. f

  and hrr_v angMom_a angMom_b angMom_c angMom_d =

    match (angMom_b.Po.tot, angMom_d.Po.tot) with
    | (_,0) -> if angMom_b.Po.tot = 0 then
          vrr_v angMom_a angMom_c
      else
        hrr0_v angMom_a angMom_b angMom_c 
    | (_,_) ->
      let xyz  = get_xyz angMom_d in
      let cp = Po.incr xyz angMom_c in
      let dm = Po.decr xyz angMom_d in 
      let h1 = 
        hrr_v angMom_a angMom_b cp dm 
      in
      let f = Co.get xyz center_cd in
      if abs_float f < cutoff then
        h1
      else
        let h2 =
          hrr_v angMom_a angMom_b angMom_c dm 
        in h1 +. f *. h2
  in
  hrr_v angMom_a angMom_b angMom_c angMom_d







let contracted_class_shell_pairs ?operator ~zero_m ?schwartz_p ?schwartz_q shell_p shell_q : float Zmap.t =

  let sp = Csp.shell_pairs shell_p
  and sq = Csp.shell_pairs shell_q
  and cp = Csp.coefficients shell_p
  and cq = Csp.coefficients shell_q
  in

  let np, nq = 
    Array.length sp,
    Array.length sq
  in

  try
    match Cspc.make ~cutoff shell_p shell_q with
    | None -> raise NullQuartet
    | Some shell_pair_couple -> 

      let shell_a = Cspc.shell_a shell_pair_couple
      and shell_c = Cspc.shell_c shell_pair_couple
      in

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

      begin
        match Cspc.ang_mom shell_pair_couple with
        | Am.S ->
          contracted_class.(0) <-
            begin
              try
                let expo_p_inv = 
                  Vector.init np (fun ab -> Psp.exponent_inv sp.(ab-1)) 
                and expo_q_inv = 
                  Vector.init nq (fun cd -> Psp.exponent_inv sq.(cd-1))
                in

                let coef =
                  Matrix.outer_product (Vector.of_array @@ cq) (Vector.of_array @@ cp)
                in
                let coefx = Matrix.to_bigarray_inplace coef in

                let zm_array = Matrix.init_cols np nq (fun i j ->
                    try
                      if (abs_float coefx.{j,i} ) < 1.e-3*.cutoff then
                        raise NullQuartet;

                      let expo_p_inv, expo_q_inv =
                        (expo_p_inv%.(i)),
                        (expo_q_inv%.(j))
                      in

                      let center_pq =
                        Co.(Psp.center sp.(i-1) |- Psp.center sq.(j-1))
                      and center_pa = 
                        Co.(Psp.center sp.(i-1) |- Cs.center shell_a)
                      and center_qc = 
                        Co.(Psp.center sq.(i-1) |- Cs.center shell_c)
                      in
                      let norm_pq_sq =
                        Co.dot center_pq center_pq
                      in

                      let zero = Zp.zero ?operator zero_m in
                      let zero_m_array = 
                        zero_m
                        {zero with
                          expo_p_inv ; expo_q_inv ; norm_pq_sq ;
                          center_pq ; center_pa ; center_qc ; 
                        }
                      in
                      zero_m_array.(0)
                    with NullQuartet -> 0.
                  )
                in
                Matrix.gemm_trace zm_array coef 
              with (Invalid_argument _) -> 0.
            end
        | _ -> 

          let coef =
            Array.init np (fun l -> Array.init nq (fun k -> cq.(k) *. cp.(l)) )
          in

          let norm = Cspc.norm_scales shell_pair_couple in

          let expo_p_inv = 
            Array.map (fun shell_ab -> Psp.exponent_inv shell_ab) sp
          and expo_q_inv = 
            Array.map (fun shell_cd -> Psp.exponent_inv shell_cd) sq 
          in

          let expo_b =
            Array.map (fun shell_ab -> Ps.exponent (Psp.shell_b shell_ab) ) sp
          and expo_d =
            Array.map (fun shell_cd -> Ps.exponent (Psp.shell_b shell_cd) ) sq
          in

          let center_pq =
            let result = 
              Array.init 3 (fun xyz ->
                  Array.init np (fun ab ->
                      let shell_ab = sp.(ab) in
                      Array.init nq (fun cd ->
                          let shell_cd = sq.(cd)
                          in
                          let cpq = 
                            Co.(Psp.center shell_ab |- Psp.center shell_cd)
                          in
                          match xyz with
                          | 0 -> Co.get X cpq;
                          | 1 -> Co.get Y cpq;
                          | _ -> Co.get Z cpq;
                        ) 
                    )
                )
            in function 
              | Co.X -> result.(0)
              | Co.Y -> result.(1)
              | Co.Z -> result.(2)
          in
          let center_pa =
            let result = 
              Array.init 3 (fun xyz ->
                  Array.init np (fun ab ->
                      let shell_ab = sp.(ab) in
                      let cpa = 
                        Co.(Psp.center shell_ab |- Cs.center shell_a)
                      in
                      match xyz with
                      | 0 -> Co.(get X cpa);
                      | 1 -> Co.(get Y cpa);
                      | _ -> Co.(get Z cpa);
                    ) 
                )
            in function 
              | Co.X -> result.(0)
              | Co.Y -> result.(1)
              | Co.Z -> result.(2)
          in
          let center_qc =
            let result = 
              Array.init 3 (fun xyz ->
                  Array.init nq (fun cd ->
                      let shell_cd = sq.(cd) in
                      let cqc = 
                        Co.(Psp.center shell_cd |- Cs.center shell_c)
                      in
                      match xyz with
                      | 0 -> Co.(get X cqc);
                      | 1 -> Co.(get Y cqc);
                      | _ -> Co.(get Z cqc);
                    ) 
                )
            in function 
              | Co.X -> result.(0)
              | Co.Y -> result.(1)
              | Co.Z -> result.(2)
          in
          let zero_m_array =
            let result = 
              Array.init (maxm+1) (fun _ ->
                  Array.init np (fun _ -> Array.make nq 0. ) )
            in
            let empty = Array.make (maxm+1) 0. in
            let center_qc_tmp = Array.init nq (fun cd ->
                Coordinate.make { Coordinate.
                  x = (center_qc Co.X).(cd) ;
                  y = (center_qc Co.Y).(cd) ;
                  z = (center_qc Co.Z).(cd) ;
                })
            in
            Array.iteri (fun ab _shell_ab ->
                let center_pa = Coordinate.make { Coordinate.
                    x = (center_pa Co.X).(ab) ;
                    y = (center_pa Co.Y).(ab) ;
                    z = (center_pa Co.Z).(ab) ;
                  }
                in
                let zero_m_array_tmp =
                  Array.mapi (fun cd _shell_cd ->
                      if (abs_float coef.(ab).(cd) < cutoff) then
                        empty
                      else
                        let expo_p_inv, expo_q_inv =
                          expo_p_inv.(ab), expo_q_inv.(cd)
                        in
                        let x = (center_pq X).(ab).(cd)
                        and y = (center_pq Y).(ab).(cd)
                        and z = (center_pq Z).(ab).(cd)
                        in
                        let norm_pq_sq =
                          x *. x +. y *. y +. z *. z
                        in
                        let zero = Zp.zero ?operator zero_m in
                        zero_m {zero with
                                maxm ; expo_p_inv ; expo_q_inv ; norm_pq_sq ;
                                center_pq = Coordinate.make Coordinate.{x ; y ; z} ;
                                center_pa ; center_qc = center_qc_tmp.(cd) ;
                              }
                    ) sq
                in
                (* Transpose result *)
                let coef_ab = coef.(ab) in
                for m=0 to maxm do
                  let result_m_ab = result.(m).(ab)
                  in
                  for cd=0 to nq-1 do
                    result_m_ab.(cd) <- zero_m_array_tmp.(cd).(m) *. coef_ab.(cd)
                  done
                done
              ) sp;
            result
          in

          let map_1d = Zmap.create (4*maxm)
          and map_2d = Array.init (maxm+1) (fun _ -> Zmap.create (Array.length class_indices))
          in
          (* Compute the integral class from the primitive shell quartet *)
          Array.iteri (fun i key ->
              let (angMom_a,angMom_b,angMom_c,angMom_d) =
                match Zkey.to_powers key with
                | Zkey.Twelve x -> x
                | _             -> assert false
              in
              try
                if monocentric then
                  begin
                    if ( ((1 land angMom_a.x + angMom_b.x + angMom_c.x + angMom_d.x) =1) ||
                         ((1 land angMom_a.y + angMom_b.y + angMom_c.y + angMom_d.y) =1) ||
                         ((1 land angMom_a.z + angMom_b.z + angMom_c.z + angMom_d.z) =1)
                       ) then
                      raise NullQuartet
                  end;

                (* Schwartz screening *)
                if (np+nq> 24) then
                  (
                    let schwartz_p = 
                      let key = Zkey.of_powers_twelve
                          angMom_a  angMom_b  angMom_a  angMom_b 
                      in
                      match schwartz_p with
                      | None -> 1.
                      | Some schwartz_p -> Zmap.find schwartz_p key
                    in
                    if schwartz_p < cutoff then raise NullQuartet;
                    let schwartz_q = 
                      let key = Zkey.of_powers_twelve
                          angMom_c  angMom_d  angMom_c  angMom_d 
                      in
                      match schwartz_q with
                      | None -> 1.
                      | Some schwartz_q -> Zmap.find schwartz_q key
                    in
                    if schwartz_p *. schwartz_q < cutoff2 then raise NullQuartet;
                  );

                let abcd = 
                  { expo_b ; expo_d ; expo_p_inv ; expo_q_inv ;
                    center_ab = Csp.a_minus_b shell_p;
                    center_cd = Csp.a_minus_b shell_q ;
                    center_pq ; center_pa ;
                    center_qc ; zero_m_array }
                in

                let integral = 
                  hvrr_two_e_vector (angMom_a, angMom_b, angMom_c, angMom_d)
                    abcd map_1d map_2d np nq
                in
                contracted_class.(i) <- contracted_class.(i) +. integral *. norm.(i)
              with NullQuartet -> ()
            ) class_indices

      end;

      let result = 
        Zmap.create (Array.length contracted_class)
      in
      Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
      result
  with NullQuartet -> empty


