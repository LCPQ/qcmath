open Lacaml.D
open Common

type ('a, 'b) t = Mat.t

let dim1 t = Mat.dim1 t
let dim2 t = Mat.dim2 t

let out_of_place f t =
  let result = lacpy t in
  f result;
  result

let relabel t = t
  
let make   m n x = Mat.make   m n x
let make0  m n   = Mat.make0  m n
let create m n   = Mat.create m n
let identity m   = Mat.identity m

let fill_inplace t x = Mat.fill t x

let add a b = Mat.add a b
let sub a b = Mat.sub a b
let mul a b = Mat.mul a b
let div a b = Mat.div a b

let add_inplace ~c a b = ignore @@ Mat.add ~c a b
let sub_inplace ~c a b = ignore @@ Mat.sub ~c a b
let mul_inplace ~c a b = ignore @@ Mat.mul ~c a b
let div_inplace ~c a b = ignore @@ Mat.div ~c a b

let add_const_diag_inplace x a =
  Mat.add_const_diag x a

let add_const_diag x a =
  out_of_place (fun t -> add_const_diag_inplace x t) a

let add_const_inplace x a =
  ignore @@ Mat.add_const x ~b:a a

let add_const x a =
  Mat.add_const x a

external to_bigarray_inplace : ('a,'b) t -> (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t = "%identity"

external of_bigarray_inplace : (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t -> ('a,'b) t = "%identity"

let to_bigarray t = lacpy t
let of_bigarray t = lacpy t

let reshape_inplace m n a =
  assert ( (dim1 a) * (dim2 a) = m*n);
  let b = 
    to_bigarray a 
    |> Bigarray.genarray_of_array2
  in
  Bigarray.reshape_2 b m n

let reshape_vec_inplace m n v =
  assert ( Vector.dim v = m*n);
  let b = 
    Vector.to_bigarray_inplace v 
    |> Bigarray.genarray_of_array1
  in
  Bigarray.reshape_2 b m n

let col_inplace t j =
  Mat.col t j
  |> Vector.of_bigarray_inplace

let transpose t =
  Mat.transpose_copy t

let transpose_inplace t =
  let mat = to_bigarray_inplace t in
  let d1 = dim1 t in
  let d2 = dim2 t in
  assert (d1 = d2);
  for j=1 to d1 do
    for i=1 to (j-1) do
      let ij, ji = mat.{i,j}, mat.{j,i} in
      mat.{i,j} <- ji;
      mat.{j,i} <- ij
    done;
  done

let to_col_vecs t =
  Mat.to_col_vecs t
  |> Array.map Vector.of_bigarray_inplace

let to_col_vecs_list t =
  Mat.to_col_vecs_list t
  |> List.rev_map Vector.of_bigarray_inplace
  |> List.rev

let detri_inplace t = 
  Mat.detri t

let detri t =
  out_of_place detri_inplace t

let as_vec_inplace t =
  Mat.as_vec t
  |> Vector.of_bigarray_inplace

let as_vec t = 
  lacpy t
  |> Mat.as_vec
  |> Vector.of_bigarray_inplace

let random ?rnd_state ?(from= -. 1.0) ?(range=2.0) m n =
  Mat.random ?rnd_state ~from ~range m n

let map_inplace f ~b a = 
  ignore @@ Mat.map f ~b a

let map f a = 
  Mat.map f a

let scale_inplace x t = 
  Mat.scal x t 

let scale x t = 
  out_of_place (fun t -> scale_inplace x t) t

let of_diag v =
  Vector.to_bigarray_inplace v
  |> Mat.of_diag 

let diag t =
  Mat.copy_diag t
  |> Vector.of_bigarray_inplace
       
let gemv_n_inplace ?m ?n ?(beta=0.) y ?(alpha=1.) ?(ar=1) ?(ac=1) t v =
  let y = Vector.to_bigarray_inplace y in
  let v = Vector.to_bigarray_inplace v in
  ignore @@ gemv ?m ?n ~beta ~trans:`N ~y ~alpha ~ar ~ac t v

let gemv_t_inplace ?m ?n ?(beta=0.) y ?(alpha=1.) ?(ar=1) ?(ac=1) t v =
  let y = Vector.to_bigarray_inplace y in
  let v = Vector.to_bigarray_inplace v in
  ignore @@ gemv ?m ?n ~beta ~trans:`T ~y ~alpha ~ar ~ac t v

let gemv_n ?m ?n ?(beta=0.) ?y ?(alpha=1.) ?(ar=1) ?(ac=1) t v =
  let v = Vector.to_bigarray_inplace v in
  let y =
    match y with
    | None -> None
    | Some y -> Some (Vector.to_bigarray_inplace y)
  in
  gemv ?m ?n ~beta ?y ~trans:`N ~alpha ~ar ~ac t v
  |> Vector.of_bigarray_inplace

let gemv_t ?m ?n ?(beta=0.) ?y ?(alpha=1.) ?(ar=1) ?(ac=1) t v =
  let v = Vector.to_bigarray_inplace v in
  let y =
    match y with
    | None -> None
    | Some y -> Some (Vector.to_bigarray_inplace y)
  in
  gemv ?m ?n ~beta ?y ~trans:`T ~alpha ~ar ~ac t v
  |> Vector.of_bigarray_inplace

let gemm_inplace ?m ?n ?k ?(beta=0.) ~c ?(transa=`N) ?(alpha=1.0) a ?(transb=`N) b =
  ignore @@ gemm ?m ?n ?k ~beta ~c ~transa ~alpha a ~transb b

let gemm_nn_inplace ?m ?n ?k ?(beta=0.) ~c ?(alpha=1.0) a b =
  gemm_inplace ?m ?n ?k ~beta ~c ~alpha a b ~transa:`N ~transb:`N

let gemm_nt_inplace ?m ?n ?k ?(beta=0.) ~c ?(alpha=1.0) a b =
  gemm_inplace ?m ?n ?k ~beta ~c ~alpha a b ~transa:`N ~transb:`T

let gemm_tn_inplace ?m ?n ?k ?(beta=0.) ~c ?(alpha=1.0) a b =
  gemm_inplace ?m ?n ?k ~beta ~c ~alpha a b ~transa:`T ~transb:`N

let gemm_tt_inplace ?m ?n ?k ?(beta=0.) ~c ?(alpha=1.0) a b =
  gemm_inplace ?m ?n ?k ~beta ~c ~alpha a b ~transa:`T ~transb:`T


let gemm ?m ?n ?k ?beta ?c ?(transa=`N) ?(alpha=1.0) a ?(transb=`N) b =
  let c =
    match c with
    | Some x -> Some (lacpy x)
    | None -> None
  in
  gemm ?m ?n ?k ?beta ?c ~transa ~alpha a ~transb b

let gemm_nn ?m ?n ?k ?beta ?c ?(alpha=1.0) a b =
  gemm ?m ?n ?k ?beta ?c ~alpha a b ~transa:`N ~transb:`N

let gemm_nt ?m ?n ?k ?beta ?c ?(alpha=1.0) a b =
  gemm ?m ?n ?k ?beta ?c ~alpha a b ~transa:`N ~transb:`T

let gemm_tn ?m ?n ?k ?beta ?c ?(alpha=1.0) a b =
  gemm ?m ?n ?k ?beta ?c ~alpha a b ~transa:`T ~transb:`N

let gemm_tt ?m ?n ?k ?beta ?c ?(alpha=1.0) a b =
  gemm ?m ?n ?k ?beta ?c ~alpha a b ~transa:`T ~transb:`T


let gemm_trace ?(transa=`N) a ?(transb=`N) b =
  Mat.gemm_trace ~transa a ~transb b
  
let gemm_nn_trace a b = gemm_trace a b ~transa:`N ~transb:`N 
let gemm_nt_trace a b = gemm_trace a b ~transa:`N ~transb:`T 
let gemm_tn_trace a b = gemm_trace a b ~transa:`T ~transb:`N 
let gemm_tt_trace a b = gemm_trace a b ~transa:`T ~transb:`T 

let init_cols = Mat.init_cols

let of_col_vecs a =
  Array.map Vector.to_bigarray_inplace a
  |> Mat.of_col_vecs 

let of_col_vecs_list a =
  List.rev_map Vector.to_bigarray_inplace a
  |> List.rev
  |> Mat.of_col_vecs_list 

let of_array a =
  Bigarray.Array2.of_array Bigarray.Float64 Bigarray.fortran_layout a
    
let to_array a =
  let result = Array.make_matrix (Mat.dim1 a) (Mat.dim2 a) 0. in
  for i=1 to Mat.dim1 a do
    let result_i = result.(i-1) in
    for j=1 to Mat.dim2 a do
      result_i.(j-1) <- a.{i,j}
    done
  done;
  result
    
let normalize_mat_inplace t = 
  let norm = Mat.as_vec t |> nrm2 in
  Mat.scal norm t

let normalize_mat t = 
  out_of_place normalize_mat_inplace t

let diagonalize_symm m_H =
  let m_V = lacpy m_H in
  let result =
    syevd ~vectors:true m_V
    |> Vector.of_bigarray_inplace
  in
  m_V, result

let sycon t =
  lacpy t
  |> sycon

let xt_o_x ~o ~x =
  gemm o x
  |> gemm ~transa:`T x

let x_o_xt ~o ~x =
  gemm o x ~transb:`T
  |> gemm x

let amax t =
  Mat.as_vec t |> amax 
    
let pp ppf m =
  let rows = Mat.dim1 m
  and cols = Mat.dim2 m
  in
  let rec aux first last =
    if (first <= last) then begin
        Format.fprintf ppf "@[\n\n    %a@]@ " (Lacaml.Io.pp_lfmat
          ~row_labels:
            (Array.init rows (fun i -> Printf.sprintf "%d  " (i + 1)))
          ~col_labels:
            (Array.init (min 5 (cols-first+1)) (fun i -> Printf.sprintf "-- %d --" (i + first) ))
          ~print_right:false
          ~print_foot:false
          () ) (lacpy ~ac:first ~n:(min 5 (cols-first+1)) m);
        (aux [@tailcall]) (first+5) last
    end
  in
  aux 1 cols

let sysv_inplace ~b a =
  sysv a b

let sysv ~b a = 
  out_of_place (fun b -> sysv_inplace ~b a) b

let debug_matrix name a =
  Format.printf "@[%s =\n@[%a@]@]@." name pp a

let outer_product_inplace m ?(alpha=1.0) u v =
  ger ~alpha (Vector.to_bigarray_inplace u) (Vector.to_bigarray_inplace v) m

let outer_product ?(alpha=1.0) u v =
  let m = make0 (Vector.dim u) (Vector.dim v) in
  outer_product_inplace m ~alpha u v;
  m

let of_file filename =
  let ic = Scanf.Scanning.open_in filename in
  let rec read_line accu =
    let result =
      try
        Some (Scanf.bscanf ic " %d %d %f" (fun i j v ->
          (i,j,v) :: accu))
      with End_of_file -> None
    in
    match result with
    | Some accu -> (read_line [@tailcall]) accu
    | None      -> List.rev accu
  in
  let data = read_line [] in
  Scanf.Scanning.close_in ic;
  let isize, jsize =
    List.fold_left (fun (accu_i,accu_j) (i,j,_) ->
      (max i accu_i, max j accu_j)) (0,0) data
  in
  let result =
    Lacaml.D.Mat.of_array
      (Array.make_matrix isize jsize 0.)
  in
  List.iter (fun (i,j,v) -> result.{i,j} <- v) data;
  result


let sym_of_file filename =
  let result =
    of_file filename
  in
  for j=1 to Mat.dim1 result do
    for i=1 to j do
      result.{j,i} <- result.{i,j}
    done;
  done;
  result


let copy ?m ?n ?br ?bc ?ar ?ac a =
  lacpy a ?m ?n ?br ?bc ?ar ?ac 

let copy_inplace ?m ?n ?br ?bc ~b ?ar ?ac a =
  ignore @@ lacpy ?m ?n ?br ?bc ~b ?ar ?ac a 

let scale_cols_inplace a v =
  Vector.to_bigarray_inplace v
  |> Mat.scal_cols a

let scale_cols a v =
  let a' = copy a in
  Vector.to_bigarray_inplace v
  |> Mat.scal_cols a' ;
  a'


let scale_rows_inplace v a =
  let v' = Vector.to_bigarray_inplace v in
  Mat.scal_rows v' a

let scale_rows v a =
  let a' = copy a in
  let v' = Vector.to_bigarray_inplace v in
  Mat.scal_rows v' a' ;
  a'

let svd  a =
  let d, u, vt = 
    gesvd (lacpy a)
  in
  u, (Vector.of_bigarray_inplace d), vt

let svd' a =
  let d, u, vt = 
    gesvd (lacpy a)
  in
  u, (Vector.of_bigarray_inplace d), vt


let qr a =
  let result = lacpy a in
  let tau = geqrf result in
  let r =
    let r = to_bigarray result in
    for j=1 to Mat.dim2 r do
      for i=j+1 to Mat.dim2 r do
        r.{i,j} <- 0.
      done
    done;
    of_bigarray r
  in
  orgqr ~tau result;
  let q = result in
  q, r

  
let exponential a =
  assert (dim1 a = dim2 a);
  let rec loop result accu n =
    let b = scale (1./.n) a in
    let new_accu = gemm accu b in
    let residual =
      sub new_accu accu
      |> amax
      |> abs_float
    in
    let result = add result new_accu in
    if residual > Constants.epsilon then
      loop result new_accu (n+.1.)
    else
      result
  in
  let id = identity (dim1 a) in
  loop id id 1.


let exponential_antisymmetric a =
  
  let n = dim1 a in
  assert (n = dim2 a);
  let a2 = gemm a a in
  let (u, w, vt) = svd a2 in
  let tau = Vector.map (fun x -> -. sqrt x) w in
  let cos_tau = Vector.cos tau in
  let sin_tau_tau = Vector.mul (Vector.sin tau) (Vector.reci tau) in
  let result = 
    add (gemm (scale_cols u cos_tau) vt) (gemm (scale_cols u sin_tau_tau) @@ gemm vt a)
  in
  
  (* Post-condition: Check if exp(-A) * exp(A) = I *)
  let id = identity n in
  let test = 
    gemm_tn ~beta:(-.1.0) ~c:id result result
    |> amax
    |> abs_float
  in

  (* If the exponential failed, fall back to the iterative exponential *)
  if  test < 10. *. Constants.epsilon then
    result
  else
    exponential a


let to_file ~filename ?(sym=false) ?(cutoff=0.) t =

  let oc = open_out filename in
  let n = Mat.dim1 t in
  let m = Mat.dim2 t in

  if sym then 
    for j=1 to n  do
      for i=1 to j do
        if (abs_float (t.{i,j}) > cutoff) then
          Printf.fprintf oc "%4d %4d %20.12e\n" i j (t.{i,j})
      done;
    done
  else
    for j=1 to n  do
      for i=1 to m do
        if (abs_float (t.{i,j}) > cutoff) then
          Printf.fprintf oc "%4d %4d %20.12e\n" i j (t.{i,j})
      done;
    done;
  close_out oc



  
  
let (%:) t (i,j) = t.{i,j}

let set  t i j v = t.{i,j} <- v


