(* [[file:~/QCaml/mo/localization.org::*Type][Type:3]] *)
open Linear_algebra
    
type localization_kind =
  | Edmiston
  | Boys

type mo = Mo_dim.t
type ao = Ao.Ao_dim.t
type loc

type localization_data =
  {
    coefficients : (ao, loc) Matrix.t ;
    kappa        : (loc, loc) Matrix.t ;
    scaling      : float ;
    loc_value    : float ;
    convergence  : float ;
    iteration    : int ;
  }
  
type t =
  {
    kind         : localization_kind  ;
    mo_basis     : Basis.t ;
    data         : localization_data option lazy_t array ;
    selected_mos : int list         ;
  }
  
open Common
(* Type:3 ends here *)

(* Edmiston-Rudenberg *)


(* [[file:~/QCaml/mo/localization.org::*Edmiston-Rudenberg][Edmiston-Rudenberg:1]] *)
let kappa_edmiston in_basis m_C =
  let ao_basis =
    Basis.simulation in_basis
    |> Simulation.ao_basis
  in

  let ee_ints = Ao.Basis.ee_ints ao_basis in
  let n_ao = Ao.Basis.size ao_basis in

  let n_mo = Matrix.dim2 m_C in

  (* Temp arrays for integral transformation *)
  let m_pqr =
    Bigarray.(Array3.create Float64 fortran_layout n_ao n_ao n_ao)
  in
  let m_qr_i = Matrix.create (n_ao*n_ao) n_mo in
  let m_ri_j = Matrix.create (n_ao*n_mo) n_mo in
  let m_ij_k = Matrix.create (n_mo*n_mo) n_mo in


  let m_a12 = Bigarray.(Array2.create Float64 fortran_layout n_mo n_mo) in
  let m_b12 = Bigarray.(Array2.create Float64 fortran_layout n_mo n_mo) in
  Bigarray.Array2.fill m_b12 0.;
  Bigarray.Array2.fill m_a12 0.;
  let v_d =
    Vector.init n_mo (fun _ -> 0.)
    |> Vector.to_bigarray_inplace
  in

  Array.iter (fun s ->

    Array.iter (fun r ->
      Array.iter (fun q ->
        Array.iter (fun p ->
          m_pqr.{p,q,r} <- Four_idx_storage.get_phys ee_ints p q r s
        ) (Util.array_range 1 n_ao)
      ) (Util.array_range 1 n_ao)
    ) (Util.array_range 1 n_ao);

    let m_p_qr =
      Bigarray.reshape (Bigarray.genarray_of_array3 m_pqr) [| n_ao ; n_ao*n_ao |]
      |> Bigarray.array2_of_genarray
      |> Matrix.of_bigarray_inplace
    in

    (* (qr,i) = <i r|q s> = \sum_p <p r | q s> C_{pi} *)
    Matrix.gemm_tn_inplace ~c:m_qr_i m_p_qr m_C;

    let m_q_ri =
      let x = Matrix.to_bigarray_inplace m_qr_i |> Bigarray.genarray_of_array2 in
      Bigarray.reshape_2 x n_ao (n_ao*n_mo) |> Matrix.of_bigarray_inplace
    in

    (* (ri,j) = <i r | j s> = \sum_q <i r | q s> C_{qj} *)
    Matrix.gemm_tn_inplace ~c:m_ri_j m_q_ri m_C;

    let m_r_ij =
      let x = Matrix.to_bigarray_inplace m_ri_j |> Bigarray.genarray_of_array2 in
      Bigarray.reshape_2 x n_ao (n_mo*n_mo) |> Matrix.of_bigarray_inplace
    in

    (* (ij,k) = <i k | j s> = \sum_r <i r | j s> C_{rk} *)
    Matrix.gemm_tn_inplace ~c:m_ij_k m_r_ij m_C;

    let m_ijk  =
      let x = Matrix.to_bigarray_inplace m_ij_k |> Bigarray.genarray_of_array2 in
      Bigarray.reshape x [| n_mo ; n_mo ; n_mo |]
      |> Bigarray.array3_of_genarray
    in

    let m_Cx = Matrix.to_bigarray_inplace m_C in
    Array.iter (fun j ->
      Array.iter (fun i ->
        m_b12.{i,j} <- m_b12.{i,j} +. m_Cx.{s,j} *. (m_ijk.{i,i,i} -. m_ijk.{j,i,j});
        m_a12.{i,j} <- m_a12.{i,j} +. m_ijk.{i,i,j} *. m_Cx.{s,j}  -.
                       0.25 *. ( (m_ijk.{i,i,i} -. m_ijk.{j,i,j}) *. m_Cx.{s,i} +.
                                 (m_ijk.{j,j,j} -. m_ijk.{i,j,i}) *. m_Cx.{s,j})
      ) (Util.array_range 1 n_mo);
      v_d.{j} <- v_d.{j} +.  m_ijk.{j,j,j} *. m_Cx.{s,j}
    ) (Util.array_range 1 n_mo)

  ) (Util.array_range 1 n_ao);

    let f i j = 
      if i=j then
        0.
      else
        begin
          let x = 1./. sqrt (m_b12.{i,j} *. m_b12.{i,j} +. m_a12.{i,j} *. m_a12.{i,j} ) in
          if asin  (m_b12.{i,j} /. x) > 0. then
            0.25 *. acos( -. m_a12.{i,j} *. x)
          else
            -. 0.25 *. acos( -. m_a12.{i,j} *. x )
        end
    in
  (
   Matrix.init_cols n_mo n_mo ( fun i j -> if i<=j then f i j else -. (f j i) ),
   Vector.sum (Vector.of_bigarray_inplace v_d)
  )
(* Edmiston-Rudenberg:1 ends here *)

(* Boys *)


(* [[file:~/QCaml/mo/localization.org::*Boys][Boys:1]] *)
let kappa_boys in_basis =
  let ao_basis =
    Basis.simulation in_basis
    |> Simulation.ao_basis
  in
  let multipole  = Ao.Basis.multipole ao_basis in
  fun m_C ->
    let n_mo = Matrix.dim2 m_C in
    
    let phi_x_phi = Matrix.xt_o_x ~x:m_C ~o:(multipole "x") in
    let phi_y_phi = Matrix.xt_o_x ~x:m_C ~o:(multipole "y") in
    let phi_z_phi = Matrix.xt_o_x ~x:m_C ~o:(multipole "z") in
    
    let m_b12 =
      let g x i j =
        let x_ii = x%:(i,i)  in
        let x_jj = x%:(j,j)  in
        let x_ij = x%:(i,j)  in
        (x_ii -. x_jj) *. x_ij
      in
      Matrix.init_cols n_mo n_mo (fun i j ->
        let x = 
          (g phi_x_phi i j) +. (g phi_y_phi i j) +. (g phi_z_phi i j) 
        in
        if (abs_float x > 1.e-15) then x else 0.
      ) 
    in
    
    let m_a12 =
      let g x i j =
        let x_ii = x%:(i,i)  in
        let x_jj = x%:(j,j)  in
        let x_ij = x%:(i,j)  in
        let y = x_ii -. x_jj in
        (x_ij *. x_ij) -. 0.25 *. y *. y
      in
      Matrix.init_cols n_mo n_mo (fun i j ->
        let x = 
          (g phi_x_phi i j) +. (g phi_y_phi i j) +. (g phi_z_phi i j) 
        in
        if (abs_float x > 1.e-15) then x else 0.
      ) 
    in
    
    let f i j = 
      let pi = Constants.pi in
      if i=j then
        0.
      else 
        let x = atan2 (m_b12%:(i,j)) (m_a12%:(i,j)) in
        if x >= 0. then
          0.25 *. (pi -. x)
        else
          -. 0.25 *. ( pi +. x)
    in
    (
      Matrix.init_cols n_mo n_mo ( fun i j -> if i>j then f i j else -. (f j i) ),
      let r2 x y z = x*.x +. y*.y +. z*.z in
      Vector.init n_mo ( fun i ->
        r2 (phi_x_phi%:(i,i)) (phi_y_phi%:(i,i)) (phi_z_phi%:(i,i)))
      |> Vector.sum
    )
(* Boys:1 ends here *)



(* | ~kappa~ | Returns the $\kappa$ antisymmetric matrix used for the rotation matrix and the value of the localization function |
 * | ~make~  | Performs the orbital localization                                                                                 | *)


(* [[file:~/QCaml/mo/localization.org::*Access][Access:2]] *)
let kind         t = t.kind
let simulation   t = Basis.simulation t.mo_basis
let selected_mos t = t.selected_mos

let kappa ~kind  =
  match kind with
  | Edmiston -> kappa_edmiston
  | Boys     -> kappa_boys
    

let n_iterations t =
  Array.fold_left (fun accu x ->
    match Lazy.force x with
    | Some _ -> accu + 1
    | None -> accu
  ) 0 t.data

let last_iteration t =
  Util.of_some @@ Lazy.force t.data.(n_iterations t - 1)

(*
let ao_basis t = Simulation.ao_basis (simulation t)
*)


let make ~kind ?(max_iter=500) ?(convergence=1.e-6) mo_basis selected_mos =

  let kappa_loc = kappa ~kind mo_basis in
  
  let mo_array = Matrix.to_col_vecs (Basis.mo_coef mo_basis) in
  let mos_vec_list = List.map (fun i -> mo_array.(i-1)) selected_mos in
  let x: (ao,loc) Matrix.t =
    Matrix.of_col_vecs_list mos_vec_list 
  in
  
  let next_coef kappa x = 
    let r = Matrix.exponential_antisymmetric kappa in
    let m_C = Matrix.gemm_nt x r in
    m_C
  in
  
  let data_initial = 
    let iteration = 0
    and scaling   = 0.1
    in
    let kappa, loc_value = kappa_loc x in
    let convergence = abs_float (Matrix.amax kappa) in
    let kappa = Matrix.scale scaling kappa in
    let coefficients = next_coef kappa x in
    { coefficients ; kappa ; scaling ; convergence ; loc_value ; iteration }
  in

  let iteration data = 
    let iteration = data.iteration+1 in
    let new_kappa, new_loc_value = kappa_loc data.coefficients in
    let new_convergence = abs_float (Matrix.amax new_kappa) in
    let accept =
       new_loc_value   >= data.loc_value*.0.98
    in
    if accept then
      let coefficients = next_coef new_kappa data.coefficients in
      let scaling = min 1. (data.scaling *. 1.1) in
      let kappa = Matrix.scale scaling new_kappa in
      let convergence = new_convergence in
      let loc_value = new_loc_value in
      { coefficients ; kappa ; scaling ; convergence ; loc_value ; iteration }
    else
      let scaling =
        data.scaling *. 0.5
      in
      { data with scaling ; iteration }
  in

  let array_data =

    let storage =
      Array.make max_iter None
    in

    let rec loop = function
      | 0 -> Some (iteration data_initial)
      | n -> begin
          match storage.(n) with
          | Some result -> Some result
          | None -> begin
              let data = loop (n-1) in
              match data with
              | None -> None
              | Some data -> begin
                  (* Check convergence *)
                  let converged =
                    data.convergence < convergence
                  in
                  if converged then
                    None
                  else
                    begin
                      storage.(n-1) <- Some data ;
                      storage.(n)  <- Some (iteration data);
                      storage.(n)
                    end
                end
            end
        end
    in
    Array.init max_iter (fun i -> lazy (loop i))
  in
  { kind ; mo_basis ; data = array_data ; selected_mos }
                    
              

let to_basis t = 
  let mo_basis = t.mo_basis in
  let simulation = Basis.simulation mo_basis in
  let mo_occupation = Basis.mo_occupation mo_basis in

  let data = last_iteration t in
  
  let mo_coef_array = Matrix.to_col_vecs (Basis.mo_coef mo_basis) in
  let new_mos =
    Matrix.to_col_vecs data.coefficients 
  in
  selected_mos t
  |> List.iteri (fun i j -> mo_coef_array.(j-1) <- new_mos.(i)) ;
  let mo_coef = Matrix.of_col_vecs mo_coef_array in
  Basis.make ~simulation ~mo_type:(Localized "Boys") ~mo_occupation ~mo_coef ()
(* Access:2 ends here *)

(* [[file:~/QCaml/mo/localization.org::*Printers][Printers:2]] *)
let linewidth = 60

let pp_iterations ppf t =
  let line = (String.make linewidth '-') in
  Format.fprintf ppf "@[%4s%s@]@." "" line;
  Format.fprintf ppf "@[%4s@[%5s@]@,@[%16s@]@,@[%16s@]@,@[%11s@]@]@." 
                      ""    "#" "Localization  " "Convergence" "Scaling";
  Format.fprintf ppf "@[%4s%s@]@." "" line;
  Array.iter (fun data ->
    let data = Lazy.force data in
    match data with
    | None -> ()
    | Some data ->
      let loc = data.loc_value in
      let conv = data.convergence in
      let scaling = data.scaling in
      let iteration = data.iteration in
      begin
        Format.fprintf ppf "@[%4s@[%5d@]@,@[%16.8f@]@,@[%16.4e@]@,@[%11.4f@]@]@." ""
          iteration loc conv scaling ;
      end
    ) t.data;
  Format.fprintf ppf "@[%4s%s@]@." "" line


let pp ppf t =
  Format.fprintf ppf "@.@[%s@]@." (String.make 70 '=');
  Format.fprintf ppf "@[%34s %-34s@]@." (match t.kind with
  | Boys -> "Boys"
  | Edmiston -> "Edmiston-Ruedenberg"
    ) "MO Localization";
  Format.fprintf ppf "@[%s@]@.@." (String.make 70 '=');
  Format.fprintf ppf "@[%a@]@." pp_iterations t;
(* Printers:2 ends here *)